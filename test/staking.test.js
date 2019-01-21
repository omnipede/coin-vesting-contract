import assertRevert from './helpers/assertRevert';
import EVMRevert from './helpers/EVMRevert';
import ether from './helpers/ether';

const BigNumber = web3.BigNumber;

require('chai').use(require('chai-as-promised')).use(require('chai-bignumber')(BigNumber)).should();

const Registry = artifacts.require('Registry.sol');
const Staking = artifacts.require('Staking.sol');

contract('Staking', function ([deployer, user1, user2]) {
  let registry, staking;
  
  beforeEach(async () => {
    registry = await Registry.new();
    staking = await Staking.new(registry.address);

    await registry.setContractDomain("Staking", staking.address);
  });

  describe('Sender ', function () {
    it('can stake through deposit', async () => {
      let amount = ether(1);
      await staking.deposit({ value: amount, from: user1 });
      let bal = await staking.balance(user1);
      assert.equal(amount.toNumber(), bal.toNumber());
    });

    it('can stake through transfer', async () => {
      let amount = ether(1);
      await staking.sendTransaction({ value: amount, from: user2, gas: 4e6 });
      let bal = await staking.balance(user2);
      assert.equal(amount.toNumber(), bal.toNumber());
    });
  });

});
