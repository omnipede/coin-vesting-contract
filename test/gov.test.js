const { reverting } = require('openzeppelin-solidity/test/helpers/shouldFail');

require('chai')
  .use(require('chai-bignumber')(web3.BigNumber))
  .should();

const Registry = artifacts.require('Registry.sol');
const Staking = artifacts.require('Staking.sol');
const Gov = artifacts.require('Gov.sol');
const GovImp = artifacts.require('GovImp.sol');

contract('Governance', function ([deployer, govMem1, user1]) {
  let registry, staking, govImp, gov, govDelegator;

  beforeEach(async () => {
    registry = await Registry.new();
    staking = await Staking.new(registry.address);
    govImp = await GovImp.new();
    gov = await Gov.new();
    await gov.init(registry.address, govImp.address);
    govDelegator = await GovImp.at(gov.address);
    
    await registry.setContractDomain("Staking", staking.address);
    await registry.setContractDomain("GovernanceContract", gov.address);
  });

  describe('Governance ', function () {
    it('cannot init twice', async () => {
        await reverting(gov.init(registry.address, govImp.address));
    });

  });

  describe('Member ', function () {
    it('can addProposal if deployer', async () => {
      const ret = await govDelegator.addProposal({ from: deployer });
      assert.equal(ret.receipt.status, '0x1');
    });

    it('cannot addProposal before member', async () => {
      await reverting(govDelegator.addProposal({ from: govMem1 }));
    });

    it('can vote', async () => {
    });

    it('cannot create ballot', async () => {
    });

  });

});
