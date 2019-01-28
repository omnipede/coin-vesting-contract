const { reverting } = require('openzeppelin-solidity/test/helpers/shouldFail');
const { ether } = require('openzeppelin-solidity/test/helpers/ether');

require('chai')
  .use(require('chai-bignumber')(web3.BigNumber))
  .should();

const Registry = artifacts.require('Registry.sol');
const Staking = artifacts.require('Staking.sol');
const Gov = artifacts.require('Gov.sol');
const GovImp = artifacts.require('GovImp.sol');

// eslint-disable-next-line max-len
const enode = '0x6f8a80d14311c39f35f516fa664deaaaa13e85b2f7493f37f6144d86991ec012937307647bd3b9a82abe2974e1407241d54947bbb39763a4cac9f77166ad92a0';
const ip = '127.0.0.1';
const port = 8542;

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

    // Initialize for staking
    await staking.deposit({ value: amount, from: deployer });

    // Initialize governance
    await gov.init(registry.address, govImp.address, amount, enode, ip, port);
    govDelegator = await GovImp.at(gov.address);
  });

  describe('Deployer ', function () {
    it('has enode and locked staking', async () => {
      const locked = await staking.lockedBalanceOf(deployer);
      locked.should.be.bignumber.equal(amount);
      const idx = await gov.nodeIdxFromMember(deployer);
      assert.notEqual(idx, 0);
      const [ nEnode, nIp, nPort ] = await gov.nodes(idx);
      nEnode.should.equal(enode);
      web3.toUtf8(nIp).should.equal(ip);
      nPort.should.be.bignumber.equal(port);
    });

    it('cannot init twice', async () => {
      await reverting(gov.init(registry.address, govImp.address, amount, enode, ip, port));
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
      await reverting(gov.init(registry.address, govImp.address, amount, enode, ip, port, { from: user1 }));
    });

    it('cannot addProposal', async () => {
      await reverting(govDelegator.addProposalForAddMember({ from: user1 }));
    });

  });

});
