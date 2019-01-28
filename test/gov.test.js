const { reverting } = require('openzeppelin-solidity/test/helpers/shouldFail');
const { ether } = require('openzeppelin-solidity/test/helpers/ether');

require('chai')
  .use(require('chai-bignumber')(web3.BigNumber))
  .should();

const Registry = artifacts.require('Registry.sol');
const Staking = artifacts.require('Staking.sol');
const Gov = artifacts.require('Gov.sol');
const GovImp = artifacts.require('GovImp.sol');

contract('Governance', function ([deployer, govMem1, user1]) {
  let registry, staking, govImp, gov, govDelegator;
  const amount = ether(1e2);

  beforeEach(async () => {
    registry = await Registry.new();
    staking = await Staking.new(registry.address);
    govImp = await GovImp.new();
    gov = await Gov.new();

    await registry.setContractDomain("Staking", staking.address);
    await registry.setContractDomain("GovernanceContract", gov.address);

    // Initialize staking
    await staking.deposit({ value: amount, from: deployer });

    // Initialize governance
    await gov.init(registry.address, govImp.address, amount);
    govDelegator = await GovImp.at(gov.address);
  });

  describe('Deployer ', function () {
    it('cannot init twice', async () => {
      await reverting(gov.init(registry.address, govImp.address, amount));
    });

    it('can addProposal for adding member', async () => {
      const ret = await govDelegator.addProposalForAddMember({ from: deployer });
      assert.equal(ret.receipt.status, '0x1');
    });

    it('can vote', async () => {
      const ret = await govDelegator.vote({ from: deployer });
    });
  });

  describe('One Member ', function () {
    beforeEach(async () => {
    });

    it('can addProposal for adding member', async () => {
      await reverting(govDelegator.addProposalForAddMember({ from: govMem1 }));
    });

    it('can vote', async () => {
      // const ret = await govDelegator.vote({ from: govMem1 });
    });

  });

  describe('Others ', function () {
    it('cannot init', async () => {
      await reverting(gov.init(registry.address, govImp.address, amount, { from: user1 }));
    });

    it('cannot addProposal', async () => {
      await reverting(govDelegator.addProposalForAddMember({ from: user1 }));
    });

  });

});
