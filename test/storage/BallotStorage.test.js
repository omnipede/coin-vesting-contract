/*jslint node: true */
const ERROR_MSG = 'VM Exception while processing transaction: revert';
const { reverting } = require('openzeppelin-solidity/test/helpers/shouldFail');
const { ether } = require('openzeppelin-solidity/test/helpers/ether');
//const { time } = require('openzeppelin-solidity/test/helpers/time');
const Registry = artifacts.require('Registry.sol');
const Staking = artifacts.require('Staking.sol');
const BallotStorage = artifacts.require("BallotStorage.sol");
const ZERO_ADDRESS = '0x0000000000000000000000000000000000000000';
const util = require('ethereumjs-util');
const moment = require('moment');
var web3Utils = require('web3-utils');

require('chai')
  .use(require('chai-as-promised'))
  .use(require('chai-bignumber')(web3.BigNumber))
  .should();

contract('BallotStorage', accounts => {
    const [deployer, creator, addMem,addMem2,govAddr,govAddr2] = accounts;
    let registry, staking,ballotStorage;

  beforeEach(async () => {
    registry = await Registry.new();
    staking = await Staking.new(registry.address);
    await registry.setContractDomain("Staking", staking.address);
    ballotStorage = await BallotStorage.new(registry.address);
    await registry.setContractDomain("BallotStorage", ballotStorage.address);
    await registry.setContractDomain("GovernanceContract", govAddr);
  });

    describe('Ballot', function () {
        //1. 투표 생성 - 멤버 추가 member 생성 ( onlyGov 체크) - O
        //2. 투표 생성 - 멤버 삭제  ( onlyGov 체크) - O
        //3. 투표 생성 - 멤버 교체  ( onlyGov 체크) - O
        //4. 투표 생성 - 멤버 가버넌스 컨트렉트 교체  ( onlyGov 체크) - O
        //5. 투표 생성 - 환경 변수 변경  ( onlyGov 체크) - O
        //6. 이미 생성된 투표 체크 (ballotId) - O
        //7. start<end time Error

        it('Canot create Ballot for MemberAdd.(not govAddr', async () => {
            let _id = new web3.BigNumber(1);
            let _start_date = moment.utc().add(20, 'seconds').unix();
            let _end_date = moment.utc().add(10, 'days').unix();
            let _ballotType = new web3.BigNumber(1);
            let _memo= "test message for ballot";
            let _enodeid = web3Utils.hexToBytes('0x6f8a80d14311c39f35f516fa664deaaaa13e85b2f7493f37f6144d86991ec012937307647bd3b9a82abe2974e1407241d54947bbb39763a4cac9f77166ad92a0');
            let _nodeip = "123.11.111.111";
            let _nodePort = 9545;
            await reverting(ballotStorage.createBallotForMemeber(
                _id,  //ballot id 
                _start_date, // start_date
                _end_date,// end_date
                _ballotType,  //ballot type
                creator,  //creator
                _memo, //memo
                ZERO_ADDRESS, // oldMemberAddress
                addMem, // newMemberAddress
                _enodeid, //newNodeId
                _nodeip, //newNodeIp
                _nodePort, //newNodePort
                { value: 0, from: creator }
            ));


        });
        it('Canot create Ballot for MemberAdd by Invalid param(oldMemberAddress)', async () => {
            let _id = new web3.BigNumber(1);
            let _start_date = moment.utc().add(20, 'seconds').unix();
            let _end_date = moment.utc().add(10, 'days').unix();
            let _ballotType = new web3.BigNumber(1);
            let _memo= "test message for ballot";
            let _enodeid = web3Utils.hexToBytes('0x6f8a80d14311c39f35f516fa664deaaaa13e85b2f7493f37f6144d86991ec012937307647bd3b9a82abe2974e1407241d54947bbb39763a4cac9f77166ad92a0');
            let _nodeip = "123.11.111.111";
            let _nodePort = 9545;
            //case oldMemberAddress is set
            await reverting(ballotStorage.createBallotForMemeber(
                _id,  //ballot id 
                _start_date, // start_date
                _end_date,// end_date
                _ballotType,  //ballot type
                creator,  //creator
                _memo, //memo
                addMem, // oldMemberAddress
                addMem2, // newMemberAddress
                _enodeid, //newNodeId
                _nodeip, //newNodeIp
                _nodePort, //newNodePort
                { value: 0, from: creator }
            ));
        });
        it('Canot create Ballot for MemberAdd by Invalid param(mewMemberAddress)', async () => {
            let _id = new web3.BigNumber(1);
            let _start_date = moment.utc().add(20, 'seconds').unix();
            let _end_date = moment.utc().add(10, 'days').unix();
            let _ballotType = new web3.BigNumber(1);
            let _memo= "test message for ballot";
            let _enodeid = web3Utils.hexToBytes('0x6f8a80d14311c39f35f516fa664deaaaa13e85b2f7493f37f6144d86991ec012937307647bd3b9a82abe2974e1407241d54947bbb39763a4cac9f77166ad92a0');
            let _nodeip = "123.11.111.111";
            let _nodePort = 9545;
            //case mewMemberAddress is not set
            await reverting(ballotStorage.createBallotForMemeber(
                _id,  //ballot id 
                _start_date, // start_date
                _end_date,// end_date
                _ballotType,  //ballot type
                creator,  //creator
                _memo, //memo
                ZERO_ADDRESS, // oldMemberAddress
                ZERO_ADDRESS, // newMemberAddress
                _enodeid, //newNodeId
                _nodeip, //newNodeIp
                _nodePort, //newNodePort
                { value: 0, from: creator }
            ));
            await reverting(ballotStorage.createBallotForMemeber(
                _id,  //ballot id 
                _start_date, // start_date
                _end_date,// end_date
                _ballotType,  //ballot type
                creator,  //creator
                _memo, //memo
                '0xabbb12', // oldMemberAddress
                ZERO_ADDRESS, // newMemberAddress
                _enodeid, //newNodeId
                _nodeip, //newNodeIp
                _nodePort, //newNodePort
                { value: 0, from: creator }
            ));
        });
        it('Canot create Ballot for MemberAdd by null param(newNodeId)', async () => {
            let _id = new web3.BigNumber(1);
            let _start_date = moment.utc().add(20, 'seconds').unix();
            let _end_date = moment.utc().add(10, 'days').unix();
            let _ballotType = new web3.BigNumber(1);
            let _memo= "test message for ballot";
            let _enodeid ='';
            let _nodeip = "123.11.111.111";
            let _nodePort = 9545;
            
            //case newNodeId is not set
            await reverting(ballotStorage.createBallotForMemeber(
                _id,  //ballot id 
                _start_date, // start_date
                _end_date,// end_date
                _ballotType,  //ballot type
                creator,  //creator
                _memo, //memo
                ZERO_ADDRESS, // oldMemberAddress
                addMem, // newMemberAddress
                _enodeid, //newNodeId
                _nodeip, //newNodeIp
                _nodePort, //newNodePort
                { value: 0, from: creator }
            ));
        });
        it('Canot create Ballot for MemberAdd by null param(newNodeIp)', async () => {
            let _id = new web3.BigNumber(1);
            let _start_date = moment.utc().add(20, 'seconds').unix();
            let _end_date = moment.utc().add(10, 'days').unix();
            let _ballotType = new web3.BigNumber(1);
            let _memo= "test message for ballot";
            let _enodeid = web3Utils.hexToBytes('0x6f8a80d14311c39f35f516fa664deaaaa13e85b2f7493f37f6144d86991ec012937307647bd3b9a82abe2974e1407241d54947bbb39763a4cac9f77166ad92a0');
            let _nodeip = '';
            let _nodePort = 9545;

            //case newNodeIp is not set
            await reverting(ballotStorage.createBallotForMemeber(
                _id,  //ballot id 
                _start_date, // start_date
                _end_date,// end_date
                _ballotType,  //ballot type
                creator,  //creator
                _memo, //memo
                ZERO_ADDRESS, // oldMemberAddress
                addMem, // newMemberAddress
                _enodeid, //newNodeId
                _nodeip, //newNodeIp
                _nodePort, //newNodePort
                { value: 0, from: creator }
            ));
        });
        it('Canot create Ballot for MemberAdd by null param(newNodePort)', async () => {
            let _id = new web3.BigNumber(1);
            let _start_date = moment.utc().add(20, 'seconds').unix();
            let _end_date = moment.utc().add(10, 'days').unix();
            let _ballotType = new web3.BigNumber(1);
            let _memo= "test message for ballot";
            let _enodeid = web3Utils.hexToBytes('0x6f8a80d14311c39f35f516fa664deaaaa13e85b2f7493f37f6144d86991ec012937307647bd3b9a82abe2974e1407241d54947bbb39763a4cac9f77166ad92a0');
            let _nodeip = "123.11.111.111";
            let _nodePort = 0;

             //case newNodePort is not set
             await reverting(ballotStorage.createBallotForMemeber(
                _id,  //ballot id 
                _start_date, // start_date
                _end_date,// end_date
                _ballotType,  //ballot type
                creator,  //creator
                _memo, //memo
                ZERO_ADDRESS, // oldMemberAddress
                addMem, // newMemberAddress
                _enodeid, //newNodeId
                _nodeip, //newNodeIp
                _nodePort, //newNodePort
                { value: 0, from: creator }
            ));
        });



        it('create Ballot for MemberAdd', async () => {
            let _id = 1;
            let _start_date = moment.utc().add(20, 'seconds').unix();
            let _end_date = moment.utc().add(10, 'days').unix();
            let _ballotType = 1; // new web3.BigNumber(1);
            let _memo= "test message for ballot";
            let _enodeid ='0x6f8a80d14311c39f35f516fa664deaaaa13e85b2f7493f37f6144d86991ec012937307647bd3b9a82abe2974e1407241d54947bbb39763a4cac9f77166ad92a0';
            //let _enodeid = web3Utils.hexToBytes(_enodidHexString);
            let _nodeip = "123.11.111.111";
            let _nodePort = 9545;
            await ballotStorage.createBallotForMemeber(
                _id,  //ballot id 
                _start_date, // start_date
                _end_date,// end_date
                _ballotType,  //ballot type
                creator,  //creator
                _memo, //memo
                ZERO_ADDRESS, // oldMemberAddress
                addMem, // newMemberAddress
                _enodeid, //newNodeId
                _nodeip, //newNodeIp
                _nodePort, //newNodePort
                { value: 0, from: govAddr }
            ); //.should.be.rejectedWith(ERROR_MSG);

            const ballotBasicInfo = await ballotStorage.getBallotBasic(_id);
            //console.log(`MemberBallotBasic : ${ballotBasicInfo}`);
            assert.equal(ballotBasicInfo[0], _id);
            assert.equal(ballotBasicInfo[1], _start_date);
            assert.equal(ballotBasicInfo[2], _end_date);
            assert.equal(ballotBasicInfo[3], _ballotType);
            assert.equal(ballotBasicInfo[4], creator);
            assert.equal(ballotBasicInfo[5], _memo);
            ballotBasicInfo[6].should.be.bignumber.equal(0);
            ballotBasicInfo[7].should.be.bignumber.equal(0);
            ballotBasicInfo[8].should.be.bignumber.equal(0);
            ballotBasicInfo[9].should.be.bignumber.equal(1);
            assert.equal(ballotBasicInfo[10], false);

            const ballotDetailInfo = await ballotStorage.getBallotMember(_id);
            //console.log(`MemberBallot : ${ballotDetailInfo}`);
            assert.equal(ballotDetailInfo[0], _id);
            assert.equal(ballotDetailInfo[1], ZERO_ADDRESS);
            assert.equal(ballotDetailInfo[2], addMem);
            assert.equal(ballotDetailInfo[3], _enodeid);
            assert.equal(ballotDetailInfo[4], _nodeip);
            assert.equal(ballotDetailInfo[5], _nodePort);

        });
        it('cannot create Ballot by duplicated id ', async () => {
            let _id = 1;
            let _start_date = moment.utc().add(20, 'seconds').unix();
            let _end_date = moment.utc().add(10, 'days').unix();
            let _ballotType = 1; // new web3.BigNumber(1);
            let _memo= "test message for ballot";
            let _enodeid ='0x6f8a80d14311c39f35f516fa664deaaaa13e85b2f7493f37f6144d86991ec012937307647bd3b9a82abe2974e1407241d54947bbb39763a4cac9f77166ad92a0';
            //let _enodeid = web3Utils.hexToBytes(_enodidHexString);
            let _nodeip = "123.11.111.111";
            let _nodePort = 9545;
            await ballotStorage.createBallotForMemeber(
                _id,  //ballot id 
                _start_date, // start_date
                _end_date,// end_date
                _ballotType,  //ballot type
                creator,  //creator
                _memo, //memo
                ZERO_ADDRESS, // oldMemberAddress
                addMem, // newMemberAddress
                _enodeid, //newNodeId
                _nodeip, //newNodeIp
                _nodePort, //newNodePort
                { value: 0, from: govAddr }
            ); //.should.be.rejectedWith(ERROR_MSG);

            let _start_date2 = moment.utc().add(20, 'seconds').unix();
            let _end_date2 = moment.utc().add(10, 'days').unix();
            let _ballotType2 = 1; // new web3.BigNumber(1);
            let _memo2= "test message for ballot2";
            let _enodeid2 ='0x6f8a80d14311c39f35f516fa664deaaaa13e85b2f7493f37f6144d86991ec012937307647bd3b9a82abe2974e1407241d54947bbb39763a4cac9f77166ad92bb';
            //let _enodeid = web3Utils.hexToBytes(_enodidHexString);
            let _nodeip2 = "123.11.111.112";
            let _nodePort2 = 9541;
            await reverting( ballotStorage.createBallotForMemeber(
                _id,  //ballot id 
                _start_date2, // start_date
                _end_date2,// end_date
                _ballotType2,  //ballot type
                creator,  //creator
                _memo2, //memo
                ZERO_ADDRESS, // oldMemberAddress
                addMem2, // newMemberAddress
                _enodeid2, //newNodeId
                _nodeip2, //newNodeIp
                _nodePort2, //newNodePort
                { value: 0, from: govAddr }
            )); //.should.be.rejectedWith(ERROR_MSG);

            const ballotBasicInfo = await ballotStorage.getBallotBasic(_id);
            //console.log(`MemberBallotBasic : ${ballotBasicInfo}`);
            assert.equal(ballotBasicInfo[0], _id);
            assert.equal(ballotBasicInfo[1], _start_date);
            assert.equal(ballotBasicInfo[2], _end_date);
            assert.equal(ballotBasicInfo[3], _ballotType);
            assert.equal(ballotBasicInfo[4], creator);
            assert.equal(ballotBasicInfo[5], _memo);
            ballotBasicInfo[6].should.be.bignumber.equal(0);
            ballotBasicInfo[7].should.be.bignumber.equal(0);
            ballotBasicInfo[8].should.be.bignumber.equal(0);
            ballotBasicInfo[9].should.be.bignumber.equal(1);
            assert.equal(ballotBasicInfo[10], false);

            const ballotDetailInfo = await ballotStorage.getBallotMember(_id);
            //console.log(`MemberBallot : ${ballotDetailInfo}`);
            assert.equal(ballotDetailInfo[0], _id);
            // assert.equal(ballotDetailInfo[1], ZERO_ADDRESS);
            assert.equal(ballotDetailInfo[2], addMem);
            assert.equal(ballotDetailInfo[3], _enodeid);
            assert.equal(ballotDetailInfo[4], _nodeip);
            assert.equal(ballotDetailInfo[5], _nodePort);

        });

        it('Canot create Ballot for Governance Address(not govAddr)', async () => {
            let _id = new web3.BigNumber(2);
            let _start_date = moment.utc().add(20, 'seconds').unix();
            let _end_date = moment.utc().add(10, 'days').unix();
            let _ballotType = new web3.BigNumber(4);
            let _memo= "test message for ballot";

            await reverting(ballotStorage.createBallotForAddress(
                _id,  //ballot id 
                _start_date, // start_date
                _end_date,// end_date
                _ballotType,  //ballot type
                creator,  //creator
                _memo, //memo
                govAddr2, //new governance contract address
                { value: 0, from: creator }
            ));
        });
        it('create Ballot for Governance Address', async () => {

            let _id = 3;
            let _start_date = moment.utc().add(20, 'seconds').unix();
            let _end_date = moment.utc().add(10, 'days').unix();
            let _ballotType = new web3.BigNumber(4);
            let _memo= "test message for ballot";
            await ballotStorage.createBallotForAddress(
                _id,  //ballot id 
                _start_date, // start_date
                _end_date,// end_date
                _ballotType,  //ballot type
                creator,  //creator
                _memo, //memo
                govAddr2, //new governance contract address
                { value: 0, from: govAddr }
            ); //.should.be.rejectedWith(ERROR_MSG);

            const ballotBasicInfo = await ballotStorage.getBallotBasic(_id);
            //console.log(`BallotBasic : ${ballotBasicInfo}`);
            assert.equal(ballotBasicInfo[0], _id);
            assert.equal(ballotBasicInfo[1], _start_date);
            assert.equal(ballotBasicInfo[2], _end_date);
            //assert.equal(ballotBasicInfo[3], _ballotType);
            ballotBasicInfo[3].should.be.bignumber.equal(_ballotType);
            assert.equal(ballotBasicInfo[4], creator);
            assert.equal(ballotBasicInfo[5], _memo);
            ballotBasicInfo[6].should.be.bignumber.equal(0);
            ballotBasicInfo[7].should.be.bignumber.equal(0);
            ballotBasicInfo[8].should.be.bignumber.equal(0);
            ballotBasicInfo[9].should.be.bignumber.equal(1);
            assert.equal(ballotBasicInfo[10],false);

            const ballotDetailInfo = await ballotStorage.getBallotAddress(_id);
            //console.log(`MemberBallot : ${ballotDetailInfo}`);
            assert.equal(ballotDetailInfo[0], _id);
            assert.equal(ballotDetailInfo[1], govAddr2);
        });
        it('Canot create Ballot for Enviroment Variable(not govAddr)', async () => {
            let _id = new web3.BigNumber(4);
            let _start_date = moment.utc().add(20, 'seconds').unix();
            let _end_date = moment.utc().add(10, 'days').unix();
            let _ballotType = new web3.BigNumber(4);
            let _memo= "test message for ballot";
            let _varName = web3.sha3('blockPer');
            let _varType = new web3.BigNumber(2);
            let _varVal = new web3.BigNumber(1000);
            await reverting(ballotStorage.createBallotForVariable(
                _id,  //ballot id 
                _start_date, // start_date
                _end_date,// end_date
                _ballotType,  //ballot type
                creator,  //creator
                _memo, //memo
                _varName,
                _varType,
                _varVal,
                { value: 0, from: creator }
            ));
        });
        it('create Ballot for Enviroment Variable', async () => {
            let _id = new web3.BigNumber(4);
            let _start_date = moment.utc().add(20, 'seconds').unix();
            let _end_date = moment.utc().add(10, 'days').unix();
            let _ballotType = new web3.BigNumber(5);
            let _memo= "test message for ballot";
            let _varName = web3.sha3('blockPer');
            let _varType = new web3.BigNumber(2);
            //let _varVal = web3Utils.numberToHex( new web3.BigNumber(1000));
            //let _varVal = util.bufferToHex(util.setLengthLeft(-1000, 32));
            let _varVal = web3.fromDecimal(-1);
            await ballotStorage.createBallotForVariable(
                _id,  //ballot id 
                _start_date, // start_date
                _end_date,// end_date
                _ballotType,  //ballot type
                creator,  //creator
                _memo, //memo
                _varName,
                _varType,
                _varVal,
                { value: 0, from: govAddr }
            ); //.should.be.rejectedWith(ERROR_MSG);

            const ballotBasicInfo = await ballotStorage.getBallotBasic(_id);
            //console.log(`MemberBallotBasic : ${ballotBasicInfo}`);
            //assert.equal(ballotBasicInfo[0], _id);
            ballotBasicInfo[0].should.be.bignumber.equal(_id);
            assert.equal(ballotBasicInfo[1], _start_date);
            assert.equal(ballotBasicInfo[2], _end_date);
            //assert.equal(ballotBasicInfo[3], _ballotType);
            ballotBasicInfo[3].should.be.bignumber.equal(_ballotType);
            assert.equal(ballotBasicInfo[4], creator);
            assert.equal(ballotBasicInfo[5], _memo);
            ballotBasicInfo[6].should.be.bignumber.equal(0);
            ballotBasicInfo[7].should.be.bignumber.equal(0);
            ballotBasicInfo[8].should.be.bignumber.equal(0);
            ballotBasicInfo[9].should.be.bignumber.equal(1);
            assert.equal(ballotBasicInfo[10], false);

            const ballotDetailInfo = await ballotStorage.getBallotVariable(_id);
            // console.log(`VariableBallot : ${ballotDetailInfo}`);
            //assert.equal(ballotDetailInfo[0], _id);
            ballotDetailInfo[0].should.be.bignumber.equal(_id);
            assert.equal(ballotDetailInfo[1], _varName);
            //assert.equal(ballotDetailInfo[2], _varType);
            ballotDetailInfo[2].should.be.bignumber.equal(_varType);
            let _val = web3Utils.hexToNumber(ballotDetailInfo[3]);
            // console.log(`Variable Value : ${_val}`);
            assert.equal(ballotDetailInfo[3], _varVal);
        });
    });
    describe('Vote', function () {
        //1. Vote 등록 - 찬성 / 반대 
        //2. 이미 투표한 케이스 
        //3. Ballot이 없는 케이스
        //4. member가 아닌 케이스 
        //5. 이미 종료가된 케이스 
        //6. 
        
    });
});