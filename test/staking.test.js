import assertRevert from './helpers/assertRevert';
import EVMRevert from './helpers/EVMRevert';

const BigNumber = web3.BigNumber;

require('chai').use(require('chai-as-promised')).use(require('chai-bignumber')(BigNumber)).should();

const Registry = artifacts.require('Registry.sol');
const Staking = artifacts.require('Staking.sol');

contract('Staking', function ([deployer, admin]) {
  let registry, staking;
  
  beforeEach(async () => {
    registry = await Registry.new();
    staking = await Staking.new();

    await registry.setContractDomain("Staking", staking.address);

    await staking.setRegistry(registry.address);
  });

  describe('Sender ', function () {
    it('can send coin', async () => {
      assert.equal(true, true);
    });
  });

});
