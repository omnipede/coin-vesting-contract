const { reverting } = require('openzeppelin-solidity/test/helpers/shouldFail');
const { ether } = require('openzeppelin-solidity/test/helpers/ether');

const Registry = artifacts.require('Registry.sol');
const Staking = artifacts.require('Staking.sol');

contract('Staking', function ([deployer, user1, user2]) {
  let registry, staking;
  let amount = ether(1);
  
  beforeEach(async () => {
    registry = await Registry.new();
    staking = await Staking.new(registry.address);

    await registry.setContractDomain("Staking", staking.address);
  });

  describe('Sender ', function () {
    it('cannot stake zero', async () => {
      await reverting(staking.deposit({ value: 0, from: user1 }));
    });

    it('can stake through deposit', async () => {
      await staking.deposit({ value: amount, from: user1 });
      let bal = await staking.balance(user1);
      assert.equal(amount.toNumber(), bal.toNumber());
    });

    it('can stake through transfer', async () => {
      await staking.sendTransaction({ value: amount, from: user2, gas: 4e6 });
      let bal = await staking.balance(user2);
      assert.equal(amount.toNumber(), bal.toNumber());
    });
  });

});
