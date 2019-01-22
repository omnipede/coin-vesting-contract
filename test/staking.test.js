const { reverting } = require('openzeppelin-solidity/test/helpers/shouldFail');
const { ether } = require('openzeppelin-solidity/test/helpers/ether');
const { ethGetBalance } = require('openzeppelin-solidity/test/helpers/web3');

require('chai')
  .use(require('chai-bignumber')(web3.BigNumber))
  .should();

const Registry = artifacts.require('Registry.sol');
const Staking = artifacts.require('Staking.sol');

contract('Staking', function ([deployer, fakeGov, user, user2, user3]) {
  let registry, staking;
  const amount = ether(1e7);
  
  beforeEach(async () => {
    registry = await Registry.new();
    staking = await Staking.new(registry.address);

    await registry.setContractDomain("Staking", staking.address);
    await registry.setContractDomain("GovernanceContract", fakeGov);
  });

  describe('Staker ', function () {
    it('cannot stake zero', async () => {
      await reverting(staking.deposit({ value: 0, from: user }));
    });

    it('can stake through deposit', async () => {
      const pre = await ethGetBalance(user);
      await staking.deposit({ value: amount, from: user });
      const post = await ethGetBalance(user);
      pre.minus(post).should.be.bignumber.gt(amount);

      const bal = await staking.balanceOf(user);
      assert.equal(amount.toNumber(), bal.toNumber());
    });

    it('can stake through transfer', async () => {
      const pre = await ethGetBalance(user);
      await staking.sendTransaction({ value: amount, from: user, gas: 4e6 });
      const post = await ethGetBalance(user);
      pre.minus(post).should.be.bignumber.gt(amount);

      const bal = await staking.balanceOf(user);
      assert.equal(amount.toNumber(), bal.toNumber());
    });

    it('cannot withdraw over balance', async () => {
      await reverting(staking.withdraw(amount, { from: user }));
      await staking.deposit({ value: amount, from: user });
      const bal = await staking.balanceOf(user);
      const bal2x = bal * 2;
      await reverting(staking.withdraw(bal2x, { from: user }));
    });

    it('can withdraw partial', async () => {
      await staking.deposit({ value: amount, from: user });
      const half = amount / 2;
      await staking.withdraw(half, { from: user });
      const bal = await staking.balanceOf(user);
      bal.should.be.bignumber.equal(half);
    });

    it('can withdraw all', async () => {
      await staking.deposit({ value: amount, from: user });
      const bal = await staking.balanceOf(user);
      const pre = await ethGetBalance(user);
      await staking.withdraw(bal, { from: user });
      const post = await ethGetBalance(user);
      post.should.be.bignumber.gt(pre);

      const remain = await staking.balanceOf(user);
      remain.should.be.bignumber.equal(0);
    });

    it('cannot lock', async () => {
      await reverting(staking.lock(user, amount, { from: user2 }));

      await staking.deposit({ value: amount, from: user });
      await reverting(staking.lock(user, amount, { from: user2 }));
    });

    it('cannot unlock', async () => {
      await staking.deposit({ value: amount, from: user });
      await reverting(staking.unlock(user, amount, { from: user2 }));

      await staking.lock(user, amount, { from: fakeGov });
      await reverting(staking.unlock(user, amount, { from: user2 }));
    });

  });

  describe('Governance ', function () {
    beforeEach(async () => {
      await staking.deposit({ value: amount, from: user });
      await staking.lock(user, amount, { from: fakeGov });
    });

    it('cannot lock over balance', async () => {
      await reverting(staking.lock(user, amount, { from: fakeGov }));
    });

    it('can lock and user cannot withdraw after lock', async () => {
      const availBal = await staking.availableBalance(user);
      availBal.should.be.bignumber.equal(0);

      await reverting(staking.withdraw(amount, { from: user }));
    });

    it('cannot unlock over balance locked', async () => {
      await reverting(staking.unlock(user, amount*2, { from: fakeGov }));
    });

    it('can unlock', async () => {
      await staking.unlock(user, amount, { from: fakeGov });
      const availBal = await staking.availableBalance(user);
      availBal.should.be.bignumber.equal(amount);
    });

  });

  describe('Voting weight ', function () {
    beforeEach(async () => {
      await staking.deposit({ value: amount, from: user });
      await staking.deposit({ value: amount*2, from: user2 });
      await staking.deposit({ value: amount*3, from: user3 });
      await staking.lock(user, amount, { from: fakeGov });
      await staking.lock(user2, amount, { from: fakeGov });
      await staking.lock(user3, amount, { from: fakeGov });
    });

    it('can be calculated', async () => {
      const weight1 = await staking.calcVotingWeight(user);
      weight1.should.be.bignumber.gt(0);

      const weight2 = await staking.calcVotingWeight(user2);
      const weight3 = await staking.calcVotingWeight(user3);
      weight1.plus(weight2).plus(weight3).should.be.bignumber.gt(95);
    });
  });

});
