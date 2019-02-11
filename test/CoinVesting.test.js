import EVMRevert from './helpers/EVMRevert';
import latestTime from './helpers/latestTime';
import { increaseTimeTo, duration } from './helpers/increaseTime';

const ZERO_ADDRESS = '0x0000000000000000000000000000000000000000';

const BigNumber = web3.BigNumber;

require('chai')
  .use(require('chai-as-promised'))
  .use(require('chai-bignumber')(BigNumber))
  .should();

const MetadiumToken = artifacts.require('Metadium');
const CoinVesting = artifacts.require('MetadiumVesting');

contract('CoinVesting', function ([_, owner, beneficiary]) {

  const _amount = 1000;
  const amount = new BigNumber(_amount);

  beforeEach(async function () {

    this.start = latestTime() + duration.minutes(1); // +1 minute so it starts after contract instantiation
    this.cliff = duration.years(1);
    this.duration = duration.years(2);

  });

  it('reverts with a duration shorter than the cliff', async function () {
    const cliff = this.duration;
    const duration = this.cliff;

    cliff.should.be.at.least(duration);

    await CoinVesting.new(
      beneficiary, this.start, cliff, duration, true, {from: owner}
    ).should.be.rejectedWith(EVMRevert);
  });

  it('reverts with a null beneficiary', async function () {

    await CoinVesting.new(
      ZERO_ADDRESS , this.start, this.cliff, this.duration, true, {from: owner}
    ).should.be.rejectedWith(EVMRevert);
  });

  it('reverts with a null duration', async function () {
    // cliffDuration should also be 0, since the duration must be larger than the cliff
    await CoinVesting.new(
      beneficiary , this.start, 0, 0, true, {from: owner}
    ).should.be.rejectedWith(EVMRevert);
  });

  it('reverts if the end time is in the past', async function () {

    const now = await latestTime();

    this.start = now - this.duration - duration.minutes(1);

    await CoinVesting.new(
      beneficiary , this.start, this.cliff, this.duration, true, {from: owner}
    ).should.be.rejectedWith(EVMRevert);
  });

  context('once deployed', function(){
    beforeEach(async function() {
      this.vesting = await CoinVesting.new(
        beneficiary, this.start, this.cliff, this.duration, true, { from: owner }
      );

      /* call fallback function. */
      await this.vesting.sendTransaction({
        value: _amount,
        from: owner,
        to: this.vesting
      });
    });

    it('can get state', async function () {

      (await this.vesting.beneficiary()).should.be.equal(beneficiary);
      (await this.vesting.cliff()).should.be.bignumber.equal(new BigNumber(this.start + this.cliff));
      (await this.vesting.start()).should.be.bignumber.equal(this.start);
      (await this.vesting.duration()).should.be.bignumber.equal(this.duration);
      (await this.vesting.revocable()).should.be.equal(true);
    });

    it('cannot be released before cliff', async function () {
      await this.vesting.release().should.be.rejectedWith(EVMRevert);
    });

    it('can be released after cliff', async function () {
      await increaseTimeTo(this.start + this.cliff + duration.weeks(1));
      await this.vesting.release().should.be.fulfilled;
    });

    it('should release proper amount after cliff', async function () {
      await increaseTimeTo(this.start + this.cliff);

      /* Before release. */
      const before = await web3.eth.getBalance(beneficiary);

      const { receipt } = await this.vesting.release();
      const releaseTime = web3.eth.getBlock(receipt.blockNumber).timestamp;

      /* After release. */
      const after = await web3.eth.getBalance(beneficiary);

      /* Released amount is (after - before). */
      const balance = await after.sub(before);
      balance.should.bignumber.equal(amount.mul(releaseTime - this.start).div(this.duration).floor());
    });

    it('should linearly release tokens during vesting period', async function () {
      const vestingPeriod = this.duration - this.cliff;
      const checkpoints = 4;

      const before = await web3.eth.getBalance(beneficiary);
      for (let i = 1; i <= checkpoints; i++) {
        const now = this.start + this.cliff + i * (vestingPeriod / checkpoints);
        await increaseTimeTo(now);

        await this.vesting.release();

        const after = await web3.eth.getBalance(beneficiary);

        const balance = await after.sub(before);
        const expectedVesting = amount.mul(now - this.start).div(this.duration).floor();

        balance.should.bignumber.equal(expectedVesting);
      }
    });

    it('should have released all after end', async function () {
      await increaseTimeTo(this.start + this.duration);

      const before = await web3.eth.getBalance(beneficiary);
      await this.vesting.release();
      const after = await web3.eth.getBalance(beneficiary);
      const balance = await after.sub(before);
      balance.should.bignumber.equal(amount);
    });

    it('should be revoked by owner if revocable is set', async function () {
      await this.vesting.revoke({ from: owner }).should.be.fulfilled;
    });

    it('should fail to be revoked by owner if revocable not set', async function () {
      const vesting = await CoinVesting.new(beneficiary, this.start, this.cliff, this.duration, false, { from: owner });
      await vesting.revoke({ from: owner }).should.be.rejectedWith(EVMRevert);
    });

    it('should return the non-vested tokens when revoked by owner', async function () {
      var gasPrice = new BigNumber(15000000000);

      await increaseTimeTo(this.start + this.cliff + duration.weeks(12));

      const vested = await this.vesting.vestedAmount();

      const before = await web3.eth.getBalance(owner);
      const {receipt} = await this.vesting.revoke({from: owner, gasPrice: gasPrice});
      var gasUsed = new BigNumber(receipt.gasUsed);
      var gasCost = gasPrice.times(gasUsed);

      var after = await (web3.eth.getBalance(owner)).add(gasCost);

      const ownerBalance = await after.sub(before);

      ownerBalance.should.bignumber.equal(amount.sub(vested));
    });

    it('should keep the vested tokens when revoked by owner', async function () {
      await increaseTimeTo(this.start + this.cliff + duration.weeks(12));

      const vestedPre = await this.vesting.vestedAmount();

      await this.vesting.revoke({ from: owner });

      const vestedPost = await this.vesting.vestedAmount();

      vestedPre.should.bignumber.equal(vestedPost);
    });

    it('should fail to be revoked a second time', async function () {
      await increaseTimeTo(this.start + this.cliff + duration.weeks(12));

      await this.vesting.vestedAmount();

      await this.vesting.revoke({ from: owner });

      await this.vesting.revoke({ from: owner }).should.be.rejectedWith(EVMRevert);
    });
  });
});
