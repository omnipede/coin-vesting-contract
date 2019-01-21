const { reverting } = require('openzeppelin-solidity/test/helpers/shouldFail');
const { ether } = require('openzeppelin-solidity/test/helpers/ether');
const { ethGetBalance } = require('openzeppelin-solidity/test/helpers/web3');

require('chai')
  .use(require('chai-bignumber')(web3.BigNumber))
  .should();

const Registry = artifacts.require('Registry.sol');
const Staking = artifacts.require('Staking.sol');

contract('Staking', function ([deployer, fakeGov, user]) {
  let registry, staking;
  const amount = ether(1);
  
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

      const bal = await staking.balance(user);
      assert.equal(amount.toNumber(), bal.toNumber());
    });

    it('can stake through transfer', async () => {
      const pre = await ethGetBalance(user);
      await staking.sendTransaction({ value: amount, from: user, gas: 4e6 });
      const post = await ethGetBalance(user);
      pre.minus(post).should.be.bignumber.gt(amount);

      const bal = await staking.balance(user);
      assert.equal(amount.toNumber(), bal.toNumber());
    });

    it('cannot withdraw over balance', async () => {
      await reverting(staking.withdraw(amount, { from: user }));
      await staking.deposit({ value: amount, from: user });
      const bal = await staking.balance(user);
      const bal2x = bal * 2;
      await reverting(staking.withdraw(bal2x, { from: user }));
    });

    it('can withdraw partial', async () => {
      await staking.deposit({ value: amount, from: user });
      const half = amount / 2;
      await staking.withdraw(half, { from: user });
      const bal = await staking.balance(user);
      bal.should.be.bignumber.equal(half);
    });

    it('can withdraw all', async () => {
      await staking.deposit({ value: amount, from: user });
      const bal = await staking.balance(user);
      const pre = await ethGetBalance(user);
      await staking.withdraw(bal, { from: user });
      const post = await ethGetBalance(user);
      post.should.be.bignumber.gt(pre);

      const remain = await staking.balance(user);
      remain.should.be.bignumber.equal(0);
    });
  });

  describe('Governance ', function () {
    beforeEach(async () => {
      await staking.deposit({ value: amount, from: user });
      await staking.lock(user, amount, { from: fakeGov });
    });

    it('can lock', async () => {
      const availBal = await staking.availBalance(user);
      availBal.should.be.bignumber.equal(0);

      await reverting(staking.withdraw(amount, { from: user }));
    });

    it('can unlock', async () => {
      await staking.unlock(user, amount, { from: fakeGov });
      const availBal = await staking.availBalance(user);
      availBal.should.be.bignumber.equal(amount);
    });
  });

});
