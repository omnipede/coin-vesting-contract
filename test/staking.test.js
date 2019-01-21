const { reverting } = require('openzeppelin-solidity/test/helpers/shouldFail');
const { ether } = require('openzeppelin-solidity/test/helpers/ether');
const { ethGetBalance } = require('openzeppelin-solidity/test/helpers/web3');

require('chai')
  .use(require('chai-bignumber')(web3.BigNumber))
  .should();

const Registry = artifacts.require('Registry.sol');
const Staking = artifacts.require('Staking.sol');

contract('Staking', function ([deployer, user1, user2]) {
  let registry, staking;
  const amount = ether(1);
  
  beforeEach(async () => {
    registry = await Registry.new();
    staking = await Staking.new(registry.address);

    await registry.setContractDomain("Staking", staking.address);
  });

  describe('Staker ', function () {
    it('cannot stake zero', async () => {
      await reverting(staking.deposit({ value: 0, from: user1 }));
    });

    it('can stake through deposit', async () => {
      const pre = await ethGetBalance(user1);
      await staking.deposit({ value: amount, from: user1 });
      const post = await ethGetBalance(user1);
      pre.minus(post).should.be.bignumber.gt(amount);

      const bal = await staking.balance(user1);
      assert.equal(amount.toNumber(), bal.toNumber());
    });

    it('can stake through transfer', async () => {
      const pre = await ethGetBalance(user2);
      await staking.sendTransaction({ value: amount, from: user2, gas: 4e6 });
      const post = await ethGetBalance(user2);
      pre.minus(post).should.be.bignumber.gt(amount);

      const bal = await staking.balance(user2);
      assert.equal(amount.toNumber(), bal.toNumber());
    });

    it('cannot withdraw over balance', async () => {
      await staking.deposit({ value: amount, from: user2 });
      const bal = await staking.balance(user2);
      const bal2x = bal * 2;
      await reverting(staking.withdraw(bal2x));
    });

    it('can withdraw unlocked balance', async () => {
      await staking.deposit({ value: amount, from: user2 });
      const bal = await staking.balance(user2);
      const pre = await ethGetBalance(user2);
      await staking.withdraw(bal, { from: user2 });
      const post = await ethGetBalance(user2);
      post.should.be.bignumber.gt(pre);

      const remain = await staking.balance(user2);
      remain.should.be.bignumber.equal(0);
    });
  });

});
