const { reverting } = require('openzeppelin-solidity/test/helpers/shouldFail');

require('chai')
  .use(require('chai-bignumber')(web3.BigNumber))
  .should();

const Registry = artifacts.require('Registry.sol');
const Staking = artifacts.require('Staking.sol');
const Gov = artifacts.require('Gov.sol');
const GovImp = artifacts.require('GovImp.sol');

contract('Governance', function ([deployer, govMem1, user1]) {
  let registry, staking, govImp, gov;

  beforeEach(async () => {
    registry = await Registry.new();
    staking = await Staking.new(registry.address);
    govImp = await GovImp.new();
    gov = await Gov.new(registry.address, govImp.address, { gas: 1e12 });
    gov = await GovImp.at(gov);

    await registry.setContractDomain("Staking", staking.address);
    await registry.setContractDomain("GovernanceContract", gov.address);
  });

  describe('Member ', function () {
    it('can addProposal', async () => {
      const ret = await gov.addProposal({ from: govMem1 });
      assert.equal(ret, true);
    });

    it('can vote', async () => {
    });

    it('cannot create ballot', async () => {
    });

  });

});
