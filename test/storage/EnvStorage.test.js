const { reverting } = require('openzeppelin-solidity/test/helpers/shouldFail');

const web3Utils = require('web3-utils');
const web3EthAbi = require('web3-eth-abi');

const Registry = artifacts.require('Registry.sol');
const EnvStorage = artifacts.require('EnvStorage.sol');
const EnvStorageImp = artifacts.require('EnvStorageImp.sol');

require('chai')
  .use(require('chai-as-promised'))
  .use(require('chai-bignumber')(web3.BigNumber))
  .should();

contract('EnvStorage', accounts => {
  const [deployer, creator, addMem, govAddr, govAddr2] = accounts;
  let registry, testEnvStorage, envStorage, envStorageImp;

  beforeEach(async () => {
    registry = await Registry.new();
    // console.log(`registry : ${registry.address}`);
    envStorageImp = await EnvStorageImp.new();
    // console.log(`envStorageImp : ${envStorageImp.address}`);
    envStorage = await EnvStorage.new(registry.address, envStorageImp.address);
    // console.log(`envStorage : ${envStorage.address}`);
    await registry.setContractDomain('EnvStorage', envStorage.address);
    await registry.setContractDomain('GovernanceContract', govAddr);

    testEnvStorage = EnvStorageImp.at(envStorage.address);
    await testEnvStorage.initialize({ from: deployer });
  });

  describe('EnvStorage', function () {
    it('Check Owner', async () => {
      const _owner = await envStorage.owner();
      assert.equal(_owner, deployer);
    });

    it('Check Registry', async () => {
      const _govAddr = await testEnvStorage.REG.call();
      assert.equal(_govAddr, registry.address);
    });

    // it('Upgrade', async () => {
    //   let newEnvStorageImp = await EnvStorageImp.new();
    //   envStorage._upgradeTo
    //   const _govAddr = await testEnvStorage.REG.call();
    //   assert.equal(_govAddr, registry.address);
    // });

    it('Check Variable Default Value', async () => {
      const blockPer = await testEnvStorage.getBlockPerValue();
      const durationMin = await testEnvStorage.getBallotDurationMinValue();
      const durationMax = await testEnvStorage.getBallotDurationMaxValue();
      const stakingMin = await testEnvStorage.getStakingMinValue();
      const stakingMax = await testEnvStorage.getStakingMaxValue();
      blockPer.should.be.bignumber.equal(1000, 'is not Default of BlockPer');
      durationMin.should.be.bignumber.equal(604800, 'is not Default of BallotDurationMin');
      durationMax.should.be.bignumber.equal(604800, 'is not Default of BallotDurationMax');
      stakingMin.should.be.bignumber.equal(10000000000, 'is not Default of StakingMin');
      stakingMax.should.be.bignumber.equal(20000000000, 'is not Default of StakingMax');

      // assert.equal(blockPer, "1000","is not Default of BlockPer ");
      // assert.equal(durationMin, "604800","is not Default of BallotDurationMin ");
      // assert.equal(durationMax, "604800","is not Default of BallotDurationMax ");
      // assert.equal(stakingMin, "10000000000","is not Default of StakingMin ");
      // assert.equal(stakingMax, "20000000000","is not Default of StakingMax ");
    });
    
    it('Type Test', async () => {
      const _testIntBytes = '0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff9c';
      const _testInt = '-100';
      const _testIntBytes2 = web3EthAbi.encodeParameter('int', _testInt);
      let _result = await testEnvStorage.setTestIntByBytes(_testIntBytes, { value: 0, from: govAddr });
      let _value = await testEnvStorage.getTestInt();
      // console.log(`bytes32 : ${web3.sha3('stakingMax')}`);
      _value.should.be.bignumber.equal(_testInt, 'not pass test int');
      // console.log(`getTestInt : ${_value} / ${_testIntBytes2}`);

      const _testaddress = '0x961c20596e7EC441723FBb168461f4B51371D8aA';
      const _testaddressBytes = web3EthAbi.encodeParameter('address', _testaddress);
      _result = await testEnvStorage.setTestAddressByBytes(_testaddress, { value: 0, from: govAddr });
      _value = await testEnvStorage.getTestAddress();
      assert.equal(web3Utils.toChecksumAddress(_value), _testaddress, 'not pass test address');
      // console.log(`getTestAddress : ${_value} / ${_testaddressBytes}`);

      const _testBytes32 = web3.sha3('stakingMax');
      const _testBytes32Bytes = web3EthAbi.encodeParameter('string', _testBytes32);

      _result = await testEnvStorage.setTestBytes32ByBytes(_testBytes32, { value: 0, from: govAddr });
      _value = await testEnvStorage.getTestBytes32();
      assert.equal(_value, _testBytes32);
      // console.log(`getTestBytes32 :  ${_testBytes32} / ${_testBytes32Bytes} / ${_value}`);

      // const _testBytes32Bytes = web3EthAbi.encodeParameter('bytes32',_testBytes32);
      const _testBytes = '0x961c20596e7ec441723fbb168461f4b51371d8aa961c20596e7ec441723fbb168461f4b51371d8aa'; // ;
      _result = await testEnvStorage.setTestBytesByBytes(_testBytes, { value: 0, from: govAddr });
      _value = await testEnvStorage.getTestBytes();
      assert.equal(_value, _testBytes);
      // console.log(`getTestBytes : ${_value}`);

      const _testString = 'testtesttest';
      const _testStringBytes = web3Utils.fromUtf8(_testString); // web3EthAbi.encodeParameter('string', _testString);

      // console.log(`abi.encodeParameter : ${web3EthAbi.encodeParameter('string', _testString)}`);
      // ;
      _result = await testEnvStorage.setTestStringByBytes(_testStringBytes, { value: 0, from: govAddr });
      _value = await testEnvStorage.getTestString();
      assert.equal(_value, _testString);
      // console.log(`getTestString : ${_value}`);
    });

    it('Canot Set block per variable(not govAddr)', async () => {
      const BLOCK_PER_VALUE_Bytes = '0x0000000000000000000000000000000000000000000000000000000000000064';
      const BLOCK_PER_VALUE = new web3.BigNumber(100);
      await reverting(testEnvStorage.setBlockPerByBytes(BLOCK_PER_VALUE_Bytes), { value: 0, from: creator });
      await reverting(testEnvStorage.setBlockPer(BLOCK_PER_VALUE), { value: 0, from: creator });
    });

    // it('Add block per variable with VariableAdded Event', async () => {
    //   // let _testUIntBytes = web3EthAbi.encodeParameter('uint256',1000000);
    //   const _result = await testEnvStorage.setBlockPer(BLOCK_PER_VALUE, { value: 0, from: govAddr });
    //   truffleAssert.eventEmitted(_result, 'VarableChanged', (ev) => {
    //     return ev._name === web3.sha3('blockPer') && ev._value === BLOCK_PER_VALUE;
    //   });
    //   const [_type, _value] = await testEnvStorage.getBlockPer();

    //   _type.should.be.bignumber.equal(2);
    //   assert.equal(_value, BLOCK_PER_VALUE);
    //   const _ttype = await testEnvStorage.getBlockPerType();
    //   const _tvalue = await testEnvStorage.getBlockPerValue();
    //   _ttype.should.be.bignumber.equal(2);
    //   assert.equal(_tvalue, BLOCK_PER_VALUE);
    // });

    it('Update block per String variable  with VariableChange Event', async () => {
      // Update BlockPer variable
      const _blockPerValueBytes = '0x0000000000000000000000000000000000000000000000000000000000000064';
      const _blockPerValue = new web3.BigNumber(100);

      const _result = await testEnvStorage.setBlockPerByBytes(_blockPerValueBytes, { value: 0, from: govAddr });
      // truffleAssert.eventEmitted(_result, 'UintVarableChanged', (ev) => {
      //   return ev._name === web3.sha3('blockPer') && ev._value == _blockPerValue;
      // });
      const _value = await testEnvStorage.getBlockPer();
      _value.should.be.bignumber.equal(_blockPerValue);
    });

    it('Update block per uint variable  with VariableChange Event', async () => {
      // Update BlockPer variable
      const _blockPerValueStr = '100';
      const _blockPerValue = new web3.BigNumber(100);
      const _result = await testEnvStorage.setBlockPer(_blockPerValue, { value: 0, from: govAddr });
      // truffleAssert.eventEmitted(_result, 'UintVarableChanged', (ev) => {
      //   return ev._name === web3.sha3('blockPer') && ev._value == _blockPerValue;
      // });
      const _value = await testEnvStorage.getBlockPer();
      _value.should.be.bignumber.equal(_blockPerValue);
    });

    it('Update BallotDurationMin String variable  with VariableChange Event', async () => {
      const _BallotDurationMinBytes = '0x00000000000000000000000000000000000000000000000000000000000003e8';
      const _BallotDurationMin = new web3.BigNumber(1000);
      // Update BallotDurationMin variable
      const _result = await testEnvStorage.setBallotDurationMinByBytes(_BallotDurationMinBytes, { value: 0, from: govAddr });
      // truffleAssert.eventEmitted(_result, 'UintVarableChanged', (ev) => {
      //   return ev._name === web3.sha3('ballotDurationMin') && ev._value == _BallotDurationMin;
      // });
      const _value = await testEnvStorage.getBallotDurationMin();
      _value.should.be.bignumber.equal(_BallotDurationMin);
    });

    it('Update BallotDurationMin Uint variable  with VariableChange Event', async () => {
      const _BallotDurationMin = new web3.BigNumber(1000);

      // Update BallotDurationMin variable
      const _result = await testEnvStorage.setBallotDurationMin(_BallotDurationMin, { value: 0, from: govAddr });
      // truffleAssert.eventEmitted(_result, 'UintVarableChanged', (ev) => {
      //   return ev._name === web3.sha3('ballotDurationMin') && ev._value == _BallotDurationMin;
      // });
      const _value = await testEnvStorage.getBallotDurationMin();
      _value.should.be.bignumber.equal(_BallotDurationMin);
    });

    it('Update BallotDurationMax string variable  with VariableChange Event', async () => {
      const _BallotDurationMaxBytes = '0x0000000000000000000000000000000000000000000000000000000000007530';
      const _BallotDurationMax = new web3.BigNumber(30000);
      // Update BallotDurationMax variable
      const _result = await testEnvStorage.setBallotDurationMaxByBytes(_BallotDurationMaxBytes, { value: 0, from: govAddr });
      // truffleAssert.eventEmitted(_result, 'UintVarableChanged', (ev) => {
      //   return ev._name === web3.sha3('ballotDurationMax') && ev._value == _BallotDurationMax;
      // });
      const _value = await testEnvStorage.getBallotDurationMax();
      _value.should.be.bignumber.equal(_BallotDurationMax);
    });

    it('Update BallotDurationMax int variable  with VariableChange Event', async () => {
      const _BallotDurationMax = new web3.BigNumber(30000);

      // Update BallotDurationMax variable
      const _result = await testEnvStorage.setBallotDurationMax(_BallotDurationMax, { value: 0, from: govAddr });
      // truffleAssert.eventEmitted(_result, 'UintVarableChanged', (ev) => {
      //   return ev._name === web3.sha3('ballotDurationMax') && ev._value == _BallotDurationMax;
      // });
      const _value = await testEnvStorage.getBallotDurationMax();
      _value.should.be.bignumber.equal(_BallotDurationMax);
    });

    it('Update StakingMin variable  with VariableChange Event', async () => {
      const _stakingMinBytes = '0x000000000000000000000000000000000000000000000000000000003b9aca00';
      const _stakingMin = new web3.BigNumber(1000000000);

      // Update BallotDurationMin variable
      const _result = await testEnvStorage.setStakingMinByBytes(_stakingMinBytes, { value: 0, from: govAddr });
      // truffleAssert.eventEmitted(_result, 'UintVarableChanged', (ev) => {
      //   return ev._name === web3.sha3('stakingMin') && ev._value == _stakingMin;
      // });
      const _value = await testEnvStorage.getStakingMin();
      _value.should.be.bignumber.equal(_stakingMin);
    });

    it('Update StakingMin variable  with VariableChange Event', async () => {
      const _stakingMin = new web3.BigNumber(1000000000);
      // Update BallotDurationMin variable
      const _result = await testEnvStorage.setStakingMin(_stakingMin, { value: 0, from: govAddr });
      // truffleAssert.eventEmitted(_result, 'UintVarableChanged', (ev) => {
      //   return ev._name === web3.sha3('stakingMin') && ev._value == _stakingMin;
      // });
      const _value = await testEnvStorage.getStakingMin();
      _value.should.be.bignumber.equal(_stakingMin);
    });

    it('Update StakingMax variable  with VariableChange Event', async () => {
      const _stakingMaxBytes = '0x00000000000000000000000000000000000000000000000000000006fc23ac00';
      const _stakingMax = new web3.BigNumber(30000000000);
      // Update BallotDurationMax variable
      const _result = await testEnvStorage.setStakingMaxByBytes(_stakingMaxBytes, { value: 0, from: govAddr });
      // truffleAssert.eventEmitted(_result, 'UintVarableChanged', (ev) => {
      //   return ev._name === web3.sha3('stakingMax') && ev._value == _stakingMax;
      // });
      const _value = await testEnvStorage.getStakingMax();
      _value.should.be.bignumber.equal(_stakingMax);
    });

    it('Update StakingMax variable  with VariableChange Event', async () => {
      const _stakingMax = new web3.BigNumber(30000000000);
      // Update BallotDurationMax variable
      const _result = await testEnvStorage.setStakingMax(_stakingMax, { value: 0, from: govAddr });
      // truffleAssert.eventEmitted(_result, 'UintVarableChanged', (ev) => {
      //   return ev._name === web3.sha3('stakingMax') && ev._value == _stakingMax;
      // });
      const _value = await testEnvStorage.getStakingMax();
      _value.should.be.bignumber.equal(_stakingMax);
    });
  });
});
