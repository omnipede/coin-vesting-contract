import assertRevert from './helpers/assertRevert';
import EVMRevert from './helpers/EVMRevert';

const BigNumber = web3.BigNumber;

require('chai').use(require('chai-as-promised')).use(require('chai-bignumber')(BigNumber)).should();

const Registry = artifacts.require('Registry.sol');
const Staking = artifacts.require('Staking.sol');

contract('Registry', function ([deployer, admin, user]) {
  let registry, staking;
  
  beforeEach(async () => {
    registry = await Registry.new();
    staking = await Staking.new(registry.address);
  });

  describe('Owner ', function () {
    it('can set Contract Domain', async () => {
      await registry.setContractDomain("Staking", staking.address);
      let domain = await registry.getContractAddress("Staking");
      assert.equal(domain, staking.address);
    });

    it('can set permission', async () => {
      await registry.setPermission("Staking", admin, "true")
      let permitted = await registry.getPermission("Staking", admin)
      assert.equal(permitted, true);
    });
  });

  describe('Other users ', function () {
    it('cannot set Contract Domain', async() => {
        await assertRevert(registry.setContractDomain("Staking", staking.address, { from : user }))
    });

    it('cannot set permission', async() => {
        await assertRevert(registry.setPermission("Staking", user, "true", { from : user }))
    });
  });

});
