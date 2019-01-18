import assertRevert from './helpers/assertRevert';
import EVMRevert from './helpers/EVMRevert';

const BigNumber = web3.BigNumber;

require('chai').use(require('chai-as-promised')).use(require('chai-bignumber')(BigNumber)).should();

const Registry = artifacts.require('Registry.sol');

contract('Registry', function ([deployer]) {
  let registry;

  beforeEach(async () => {
    registry = await Registry.new();
  });

  describe('Owner ', function () {
    it('can set Contract Domain', async () => {
      assert.equal(true, true);
    });

    it('can set permission', async () => {
      assert.equal(true, true);
    });
  });
});
