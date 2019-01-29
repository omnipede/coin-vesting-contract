/*jslint node: true */
const { reverting } = require('openzeppelin-solidity/test/helpers/shouldFail');
const Registry = artifacts.require('Registry.sol');
const EnvStorage = artifacts.require("EnvStorage.sol");
const EnvStorageImp = artifacts.require("EnvStorageImp.sol");
const truffleAssert = require('truffle-assertions');

require('chai')
  .use(require('chai-as-promised'))
  .use(require('chai-bignumber')(web3.BigNumber))
  .should();

contract('EnvStorage', accounts => {
    const [deployer, creator, addMem,govAddr,govAddr2] = accounts;
    let registry, testEnvStorage,envStorage,envStorageImp;

    beforeEach(async () => {
        registry = await Registry.new();
        //console.log(`registry : ${registry.address}`);
        envStorageImp = await EnvStorageImp.new();
        //console.log(`envStorageImp : ${envStorageImp.address}`);
        envStorage = await EnvStorage.new(registry.address, envStorageImp.address);
       // console.log(`envStorage : ${envStorage.address}`);
        await registry.setContractDomain("EnvStorage", envStorage.address);
        await registry.setContractDomain("GovernanceContract", govAddr);
        testEnvStorage = EnvStorageImp.at(envStorage.address);

    });

    describe('EnvStorage', function () {
        const BLOCK_PER_VALUE = "1000";
        const UPDATE_BLOCK_PER_VALUE = "100";
        it('Check Owner', async () => {
            let _owner = await envStorage.owner();
            assert.equal(_owner, deployer);
        });
        it('Check Registry', async () => {
            let _govAddr = await testEnvStorage.REG.call();
            assert.equal(_govAddr, registry.address);
        });
        it('Canot Set block per variable(not govAddr)', async () => {
            await reverting (testEnvStorage.setBlockPer(BLOCK_PER_VALUE),{ value: 0, from: creator });
        });
        it('Add block per variable with VariableAdded Event', async () => {
            // let _testUIntBytes = web3EthAbi.encodeParameter('uint256',1000000);
            let _result = await testEnvStorage.setBlockPer(BLOCK_PER_VALUE, { value: 0, from: govAddr });
            truffleAssert.eventEmitted(_result, 'VarableAdded', (ev) => {
                return ev._name === web3.sha3("blockPer") && ev._value === BLOCK_PER_VALUE;
            });
            const [_type, _value] = await testEnvStorage.getBlockPer();

            _type.should.be.bignumber.equal(2);
            assert.equal(_value,BLOCK_PER_VALUE);
            const _ttype = await testEnvStorage.getBlockPerType();
            const _tvalue = await testEnvStorage.getBlockPerValue();
            _ttype.should.be.bignumber.equal(2);
            assert.equal(_tvalue,BLOCK_PER_VALUE);
        });
        it('Update block per variable  with VariableChange Event', async () => {
            //Add BlockPer variable
            let _result = await testEnvStorage.setBlockPer(BLOCK_PER_VALUE, { value: 0, from: govAddr });
            truffleAssert.eventEmitted(_result, 'VarableAdded', (ev) => {
                return ev._name === web3.sha3("blockPer") && ev._value === BLOCK_PER_VALUE;
            });
            let [_type, _value] = await testEnvStorage.getBlockPer();
            //console.log(`BlockPer : ${_type}, ${_value}`);
            _type.should.be.bignumber.equal(2);
            assert.equal(_value,BLOCK_PER_VALUE);

            //Update BlockPer variable
            _result = await testEnvStorage.setBlockPer(UPDATE_BLOCK_PER_VALUE, { value: 0, from: govAddr });
            truffleAssert.eventEmitted(_result, 'VarableChanged', (ev) => {
                return ev._name === web3.sha3("blockPer") && ev._value === UPDATE_BLOCK_PER_VALUE;
            });
            [_type, _value] = await testEnvStorage.getBlockPer();
            //console.log(`BlockPer : ${_type}, ${_value}`);
            _type.should.be.bignumber.equal(2);
            assert.equal(_value,UPDATE_BLOCK_PER_VALUE);
            const _ttype = await testEnvStorage.getBlockPerType();
            const _tvalue = await testEnvStorage.getBlockPerValue();
            _ttype.should.be.bignumber.equal(2);
            assert.equal(_tvalue,UPDATE_BLOCK_PER_VALUE);
        });
    });
});