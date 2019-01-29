/*jslint node: true */
const ERROR_MSG = 'VM Exception while processing transaction: revert';
const { reverting } = require('openzeppelin-solidity/test/helpers/shouldFail');
const { ether } = require('openzeppelin-solidity/test/helpers/ether');
const time = require('openzeppelin-solidity/test/helpers/time');

const Registry = artifacts.require('Registry.sol');
const Staking = artifacts.require('Staking.sol');
const BallotStorage = artifacts.require("BallotStorage.sol");
const Gov = artifacts.require('Gov.sol');
const GovImp = artifacts.require('GovImp.sol');

const ZERO_ADDRESS = '0x0000000000000000000000000000000000000000';
const util = require('ethereumjs-util');
const moment = require('moment');
const web3Utils = require('web3-utils');

require('chai')
  .use(require('chai-as-promised'))
  .use(require('chai-bignumber')(web3.BigNumber))
  .should();

contract('BallotStorage', accounts => {
    const [deployer, creator, addMem,addMem2,govAddr,govAddr2,member1,member2,member3] = accounts;
    let registry, staking,ballotStorage;

    describe('Ballot', function () {
        beforeEach(async () => {
            registry = await Registry.new();
            staking = await Staking.new(registry.address);
            await registry.setContractDomain("Staking", staking.address);
            ballotStorage = await BallotStorage.new(registry.address);
            await registry.setContractDomain("BallotStorage", ballotStorage.address);
            await registry.setContractDomain("GovernanceContract", govAddr);
          });
        //1. 투표 생성 - 멤버 추가 member 생성 ( onlyGov 체크) - O
        //2. 투표 생성 - 멤버 삭제  ( onlyGov 체크) - O
        //3. 투표 생성 - 멤버 교체  ( onlyGov 체크) - O
        //4. 투표 생성 - 멤버 가버넌스 컨트렉트 교체  ( onlyGov 체크) - O
        //5. 투표 생성 - 환경 변수 변경  ( onlyGov 체크) - O
        //6. 이미 생성된 투표 체크 (ballotId) - O
        //7. start<end time Error

        it('Cannot create Ballot for MemberAdd.(not govAddr', async () => {
            let _id = new web3.BigNumber(1);
            let _ballotType = new web3.BigNumber(1);
            let _memo= "test message for ballot";
            let _enodeid = web3Utils.hexToBytes('0x6f8a80d14311c39f35f516fa664deaaaa13e85b2f7493f37f6144d86991ec012937307647bd3b9a82abe2974e1407241d54947bbb39763a4cac9f77166ad92a0');
            let _nodeip = "123.11.111.111";
            let _nodePort = 9545;
            await reverting(ballotStorage.createBallotForMemeber(
                _id,  //ballot id 
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
        it('Cannot create Ballot for MemberAdd by Invalid param(oldMemberAddress)', async () => {
            let _id = new web3.BigNumber(1);
            let _ballotType = new web3.BigNumber(1);
            let _memo= "test message for ballot";
            let _enodeid = web3Utils.hexToBytes('0x6f8a80d14311c39f35f516fa664deaaaa13e85b2f7493f37f6144d86991ec012937307647bd3b9a82abe2974e1407241d54947bbb39763a4cac9f77166ad92a0');
            let _nodeip = "123.11.111.111";
            let _nodePort = 9545;
            //case oldMemberAddress is set
            await reverting(ballotStorage.createBallotForMemeber(
                _id,  //ballot id 
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
        it('Cannot create Ballot for MemberAdd by Invalid param(mewMemberAddress)', async () => {
            let _id = new web3.BigNumber(1);
            let _ballotType = new web3.BigNumber(1);
            let _memo= "test message for ballot";
            let _enodeid = web3Utils.hexToBytes('0x6f8a80d14311c39f35f516fa664deaaaa13e85b2f7493f37f6144d86991ec012937307647bd3b9a82abe2974e1407241d54947bbb39763a4cac9f77166ad92a0');
            let _nodeip = "123.11.111.111";
            let _nodePort = 9545;
            //case mewMemberAddress is not set
            await reverting(ballotStorage.createBallotForMemeber(
                _id,  //ballot id 
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
            //case mewMemberAddress is set invalid address
            await reverting(ballotStorage.createBallotForMemeber(
                _id,  //ballot id 
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
        it('Cannot create Ballot for MemberAdd by null param(newNodeId)', async () => {
            let _id = new web3.BigNumber(1);
            let _ballotType = new web3.BigNumber(1);
            let _memo= "test message for ballot";
            let _enodeid ='';
            let _nodeip = "123.11.111.111";
            let _nodePort = 9545;
            
            //case newNodeId is not set
            await reverting(ballotStorage.createBallotForMemeber(
                _id,  //ballot id 
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
        it('Cannot create Ballot for MemberAdd by null param(newNodeIp)', async () => {
            let _id = new web3.BigNumber(1);
            let _ballotType = new web3.BigNumber(1);
            let _memo= "test message for ballot";
            let _enodeid = web3Utils.hexToBytes('0x6f8a80d14311c39f35f516fa664deaaaa13e85b2f7493f37f6144d86991ec012937307647bd3b9a82abe2974e1407241d54947bbb39763a4cac9f77166ad92a0');
            let _nodeip = '';
            let _nodePort = 9545;

            //case newNodeIp is not set
            await reverting(ballotStorage.createBallotForMemeber(
                _id,  //ballot id 
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
        it('Cannot create Ballot for MemberAdd by null param(newNodePort)', async () => {
            let _id = new web3.BigNumber(1);
            let _ballotType = new web3.BigNumber(1);
            let _memo= "test message for ballot";
            let _enodeid = web3Utils.hexToBytes('0x6f8a80d14311c39f35f516fa664deaaaa13e85b2f7493f37f6144d86991ec012937307647bd3b9a82abe2974e1407241d54947bbb39763a4cac9f77166ad92a0');
            let _nodeip = "123.11.111.111";
            let _nodePort = 0;

             //case newNodePort is not set
             await reverting(ballotStorage.createBallotForMemeber(
                _id,  //ballot id 
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
            let _start_time = 0;
            let _end_time = 0;
            let _ballotType = 1; // new web3.BigNumber(1);
            let _memo= "test message for ballot";
            let _enodeid ='0x6f8a80d14311c39f35f516fa664deaaaa13e85b2f7493f37f6144d86991ec012937307647bd3b9a82abe2974e1407241d54947bbb39763a4cac9f77166ad92a0';
            //let _enodeid = web3Utils.hexToBytes(_enodidHexString);
            let _nodeip = "123.11.111.111";
            let _nodePort = 9545;
            await ballotStorage.createBallotForMemeber(
                _id,  //ballot id 
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
            assert.equal(ballotBasicInfo[1], _start_time);
            assert.equal(ballotBasicInfo[2], _end_time);
            assert.equal(ballotBasicInfo[3], _ballotType);
            assert.equal(ballotBasicInfo[4], creator);
            assert.equal(web3Utils.toUtf8(ballotBasicInfo[5]), _memo);
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
            assert.equal(web3Utils.toUtf8(ballotDetailInfo[4]), _nodeip);
            assert.equal(ballotDetailInfo[5], _nodePort);

        });
        it('Start Ballot for MemberAdd', async () => {
            let _id = 1;
            let _start_time = moment.utc().add(20, 'seconds').unix();
            let _end_time = moment.utc().add(10, 'days').unix();
            let _ballotType = 1; // new web3.BigNumber(1);
            let _memo= "test message for ballot";
            let _enodeid ='0x6f8a80d14311c39f35f516fa664deaaaa13e85b2f7493f37f6144d86991ec012937307647bd3b9a82abe2974e1407241d54947bbb39763a4cac9f77166ad92a0';
            //let _enodeid = web3Utils.hexToBytes(_enodidHexString);
            let _nodeip = "123.11.111.111";
            let _nodePort = 9545;
            await ballotStorage.createBallotForMemeber(
                _id,  //ballot id 
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

            let ballotBasicInfo = await ballotStorage.getBallotBasic(_id);
            //console.log(`MemberBallotBasic : ${ballotBasicInfo}`);
            assert.equal(ballotBasicInfo[0], _id);
            assert.equal(ballotBasicInfo[1], 0);
            assert.equal(ballotBasicInfo[2], 0);
            assert.equal(ballotBasicInfo[3], _ballotType);
            assert.equal(ballotBasicInfo[4], creator);
            assert.equal(web3Utils.toUtf8(ballotBasicInfo[5]), _memo);
            ballotBasicInfo[6].should.be.bignumber.equal(0);
            ballotBasicInfo[7].should.be.bignumber.equal(0);
            ballotBasicInfo[8].should.be.bignumber.equal(0);
            ballotBasicInfo[9].should.be.bignumber.equal(1); //Ready
            assert.equal(ballotBasicInfo[10], false);

            await ballotStorage.startBallot(_id,_start_time,_end_time,{ value: 0, from: govAddr });
            ballotBasicInfo = await ballotStorage.getBallotBasic(_id);
            assert.equal(ballotBasicInfo[1], _start_time);
            assert.equal(ballotBasicInfo[2], _end_time);
            ballotBasicInfo[9].should.be.bignumber.equal(2); //InProgress
        });
        it('cannot create Ballot by duplicated id ', async () => {
            let _id = 1;
            let _start_time = 0;
            let _end_time = 0;
            let _ballotType = 1; // new web3.BigNumber(1);
            let _memo= "test message for ballot";
            let _enodeid ='0x6f8a80d14311c39f35f516fa664deaaaa13e85b2f7493f37f6144d86991ec012937307647bd3b9a82abe2974e1407241d54947bbb39763a4cac9f77166ad92a0';
            //let _enodeid = web3Utils.hexToBytes(_enodidHexString);
            let _nodeip = "123.11.111.111";
            let _nodePort = 9545;
            await ballotStorage.createBallotForMemeber(
                _id,  //ballot id 
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

            let _ballotType2 = 1; // new web3.BigNumber(1);
            let _memo2= "test message for ballot2";
            let _enodeid2 ='0x6f8a80d14311c39f35f516fa664deaaaa13e85b2f7493f37f6144d86991ec012937307647bd3b9a82abe2974e1407241d54947bbb39763a4cac9f77166ad92bb';
            //let _enodeid = web3Utils.hexToBytes(_enodidHexString);
            let _nodeip2 = "123.11.111.112";
            let _nodePort2 = 9541;
            await reverting( ballotStorage.createBallotForMemeber(
                _id,  //ballot id 
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
            assert.equal(ballotBasicInfo[1], _start_time); 
            assert.equal(ballotBasicInfo[2], _end_time); 
            assert.equal(ballotBasicInfo[3], _ballotType);
            assert.equal(ballotBasicInfo[4], creator);
            assert.equal(web3Utils.toUtf8(ballotBasicInfo[5]), _memo);
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
            assert.equal(web3Utils.toUtf8(ballotDetailInfo[4]), _nodeip);
            assert.equal(ballotDetailInfo[5], _nodePort);

        });

        it('Canot create Ballot for Governance Address(not govAddr)', async () => {
            let _id = new web3.BigNumber(2);
            let _ballotType = new web3.BigNumber(4);
            let _memo= "test message for ballot";

            await reverting(ballotStorage.createBallotForAddress(
                _id,  //ballot id 
                _ballotType,  //ballot type
                creator,  //creator
                _memo, //memo
                govAddr2, //new governance contract address
                { value: 0, from: creator }
            ));
        });
        it('create Ballot for Governance Address', async () => {

            let _id = 3;
            let _start_time = 0;
            let _end_time = 0;
            let _ballotType = new web3.BigNumber(4);
            let _memo= "test message for ballot";
            await ballotStorage.createBallotForAddress(
                _id,  //ballot id 
                _ballotType,  //ballot type
                creator,  //creator
                _memo, //memo
                govAddr2, //new governance contract address
                { value: 0, from: govAddr }
            ); //.should.be.rejectedWith(ERROR_MSG);

            const ballotBasicInfo = await ballotStorage.getBallotBasic(_id);
            //console.log(`BallotBasic : ${ballotBasicInfo}`);
            assert.equal(ballotBasicInfo[0], _id);
            assert.equal(ballotBasicInfo[1], _start_time);
            assert.equal(ballotBasicInfo[2], _end_time);
            //assert.equal(ballotBasicInfo[3], _ballotType);
            ballotBasicInfo[3].should.be.bignumber.equal(_ballotType);
            assert.equal(ballotBasicInfo[4], creator);
            assert.equal(web3Utils.toUtf8(ballotBasicInfo[5]),_memo);
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
            let _ballotType = new web3.BigNumber(4);
            let _memo= "test message for ballot";
            let _varName = web3.sha3('blockPer');
            let _varType = new web3.BigNumber(2);
            let _varVal = new web3.BigNumber(1000);
            await reverting(ballotStorage.createBallotForVariable(
                _id,  //ballot id 
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
            let _start_time = 0;
            let _end_time = 0;
            let _ballotType = new web3.BigNumber(5);
            let _memo= "test message for ballot";
            let _varName = web3.sha3('blockPer');
            let _varType = new web3.BigNumber(2);
            //let _varVal = web3Utils.numberToHex( new web3.BigNumber(1000));
            //let _varVal = util.bufferToHex(util.setLengthLeft(-1000, 32));
            let _varVal = web3.fromDecimal(-1);
            await ballotStorage.createBallotForVariable(
                _id,  //ballot id 
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
            assert.equal(ballotBasicInfo[1], _start_time);
            assert.equal(ballotBasicInfo[2], _end_time);
            //assert.equal(ballotBasicInfo[3], _ballotType);
            ballotBasicInfo[3].should.be.bignumber.equal(_ballotType);
            assert.equal(ballotBasicInfo[4], creator);
            assert.equal(web3Utils.toUtf8(ballotBasicInfo[5]), _memo);
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
        let _id = 1;
        let _start_time = 0;
        let _end_time = 0;
        //let after_end_time =  moment.utc().add(10, 'days').add(1,'seconds').unix();
        beforeEach(async () => {
           
            registry = await Registry.new();
            staking = await Staking.new(registry.address);
            await registry.setContractDomain("Staking", staking.address);
            ballotStorage = await BallotStorage.new(registry.address);
            await registry.setContractDomain("BallotStorage", ballotStorage.address);
            await registry.setContractDomain("GovernanceContract", govAddr);

            _start_time =  moment.utc().add(1, 'seconds').unix();
            _end_time = moment.utc().add(10, 'days').unix();
            let _ballotType = 1; // new web3.BigNumber(1);
            let _memo= "test message for ballot";
            let _enodeid ='0x6f8a80d14311c39f35f516fa664deaaaa13e85b2f7493f37f6144d86991ec012937307647bd3b9a82abe2974e1407241d54947bbb39763a4cac9f77166ad92a0';
            //let _enodeid = web3Utils.hexToBytes(_enodidHexString);
            let _nodeip = "123.11.111.111";
            let _nodePort = 9545;
            await ballotStorage.createBallotForMemeber(
                _id,  //ballot id 
                _ballotType,  //ballot type
                creator,  //creator
                _memo, //memo
                ZERO_ADDRESS, // oldMemberAddress
                addMem, // newMemberAddress
                _enodeid, //newNodeId
                _nodeip, //newNodeIp
                _nodePort, //newNodePort
                { value: 0, from: govAddr }
            );

            await ballotStorage.startBallot(_id,  _start_time, _end_time,{ value: 0, from: govAddr });

        });
        //1. Vote 등록 - 찬성 / 반대 
        //2. 이미 투표한 케이스 
        //3. Ballot이 없는 케이스
        //4. member가 아닌 케이스 
        //5. 이미 종료가된 케이스 
        //6. 

        it('create votes', async () => {

             //1st vote
            let _voteId = 1;
            let _decision = 1; //accept
            let _power = 10000;

            await ballotStorage.createVote(
                _voteId, // _voteId,
                _id,//_ballotId,
                member1,//_voter,
                _decision,//_decision,
                _power,// _power,
                { value: 0, from: govAddr }
            ); //.should.be.rejectedWith(ERROR_MSG);

            const voteInfo = await ballotStorage.getVote(_voteId);
            //console.log(`MemberBallotBasic : ${ballotBasicInfo}`);

            //assert.equal(voteInfo[0], _voteId);
            voteInfo[0].should.be.bignumber.equal(_voteId);
            //assert.equal(voteInfo[1], _Id);
            voteInfo[1].should.be.bignumber.equal(_id);
            assert.equal(voteInfo[2], member1);
            assert.equal(voteInfo[3], _decision);
            //assert.equal(voteInfo[4], _power);
            voteInfo[4].should.be.bignumber.equal(_power);

            let ballotBasicInfo = await ballotStorage.getBallotBasic(_id);
            ballotBasicInfo[6].should.be.bignumber.equal(1); //totalVoters
            ballotBasicInfo[7].should.be.bignumber.equal(_power); //powerOfAccepts
            ballotBasicInfo[8].should.be.bignumber.equal(0); //powerOfRejects

            let _hasVoted = await ballotStorage.hasAlreadyVoted(_id,member1);
            assert.equal(_hasVoted, true);

            //2nd Vote
            let _voteId2 = 2;
            let _decision2 = 1; //reject
            let _power2 = 40000;
            await ballotStorage.createVote(
                _voteId2, // _voteId,
                _id,//_ballotId,
                member2,//_voter,
                _decision2,//_decision,
                _power2,// _power,
                { value: 0, from: govAddr }
            );
            ballotBasicInfo = await ballotStorage.getBallotBasic(_id);
            ballotBasicInfo[6].should.be.bignumber.equal(2); //totalVoters
            ballotBasicInfo[7].should.be.bignumber.equal(_power+_power2); //powerOfAccepts
            ballotBasicInfo[8].should.be.bignumber.equal(0); //powerOfRejects

            _hasVoted = await ballotStorage.hasAlreadyVoted(_id,member2);
            assert.equal(_hasVoted, true);

            //3rd Vote
            let _voteId3= 3;
            let _decision3 = 2; //reject
            let _power3 = 50000;
            await ballotStorage.createVote(
                _voteId3, // _voteId,
                _id,//_ballotId,
                member3,//_voter,
                _decision3,//_decision,
                _power3,// _power,
                { value: 0, from: govAddr }
            );
            ballotBasicInfo = await ballotStorage.getBallotBasic(_id);
            ballotBasicInfo[6].should.be.bignumber.equal(3); //totalVoters
            ballotBasicInfo[7].should.be.bignumber.equal(_power+_power2); //powerOfAccepts
            ballotBasicInfo[8].should.be.bignumber.equal(_power3); //powerOfRejects

            _hasVoted = await ballotStorage.hasAlreadyVoted(_id,member3);
            assert.equal(_hasVoted, true);
        });

        it('cannot create vote - same voteId', async () => {
            let _voteId = 1;
            let _decision = 1; //accept
            let _power = 10000;

            let _decision2 =2; //Reject
            let _power2 = 20000;

            await ballotStorage.createVote(
                _voteId, // _voteId,
                _id,//_ballotId,
                member1,//_voter,
                _decision,//_decision,
                _power,// _power,
                { value: 0, from: govAddr }
            ); //.should.be.rejectedWith(ERROR_MSG);

            await reverting (ballotStorage.createVote(
                _voteId, // _voteId,
                _id,//_ballotId,
                member2,//_voter,
                _decision2,//_decision,
                _power2,// _power,
                { value: 0, from: govAddr }
            ));

            const voteInfo = await ballotStorage.getVote(_voteId);
            //console.log(`MemberBallotBasic : ${ballotBasicInfo}`);

            //assert.equal(voteInfo[0], _voteId);
            voteInfo[0].should.be.bignumber.equal(_voteId);
            //assert.equal(voteInfo[1], _Id);
            voteInfo[1].should.be.bignumber.equal(_id);
            assert.equal(voteInfo[2], member1);
            assert.equal(voteInfo[3], _decision);
            //assert.equal(voteInfo[4], _power);
            voteInfo[4].should.be.bignumber.equal(_power);

            const ballotBasicInfo = await ballotStorage.getBallotBasic(_id);
            ballotBasicInfo[6].should.be.bignumber.equal(1); //totalVoters
            ballotBasicInfo[7].should.be.bignumber.equal(_power); //powerOfAccepts
            ballotBasicInfo[8].should.be.bignumber.equal(0); //powerOfRejects

            const _hasVoted = await ballotStorage.hasAlreadyVoted(_id,member1);
            assert.equal(_hasVoted, true);
        });
        it('cannot create vote - multiple vote', async () => {
            let _voteId = 1;
            let _decision = 1; //accept
            let _power = 10000;

            let _voteId2 = 2;
            let _decision2 =2; //Reject
            let _power2 = 20000;

            await ballotStorage.createVote(
                _voteId, // _voteId,
                _id,//_ballotId,
                member1,//_voter,
                _decision,//_decision,
                _power,// _power,
                { value: 0, from: govAddr }
            ); //.should.be.rejectedWith(ERROR_MSG);

            await reverting (ballotStorage.createVote(
                _voteId2, // _voteId,
                _id,//_ballotId,
                member1,//_voter,
                _decision2,//_decision,
                _power2,// _power,
                { value: 0, from: govAddr }
            ));

            const voteInfo = await ballotStorage.getVote(_voteId);
            //console.log(`MemberBallotBasic : ${ballotBasicInfo}`);

            //assert.equal(voteInfo[0], _voteId);
            voteInfo[0].should.be.bignumber.equal(_voteId);
            //assert.equal(voteInfo[1], _Id);
            voteInfo[1].should.be.bignumber.equal(_id);
            assert.equal(voteInfo[2], member1);
            assert.equal(voteInfo[3], _decision);
            //assert.equal(voteInfo[4], _power);
            voteInfo[4].should.be.bignumber.equal(_power);

            const ballotBasicInfo = await ballotStorage.getBallotBasic(_id);
            ballotBasicInfo[6].should.be.bignumber.equal(1); //totalVoters
            ballotBasicInfo[7].should.be.bignumber.equal(_power); //powerOfAccepts
            ballotBasicInfo[8].should.be.bignumber.equal(0); //powerOfRejects
        });
        it('cannot create vote - not Existed ballot', async () => {
            let _notExistedId = 3;
            let _voteId = 1;
            let _decision = 1; //accept
            let _power = 10000;
            // await time.increaseTo(_start_time+1);
            // let _latestTime1 = await time.latest();
            // let _nowTime = await ballotStorage.getTime();
            // console.log(`step_(${_nowTime}):  ${_latestTime1},  ${_start_time}, ${_end_time}`);
            await reverting (ballotStorage.createVote(
                _voteId, // _voteId,
                _notExistedId,//_ballotId,
                member1,//_voter,
                _decision,//_decision,
                _power,// _power,
                { value: 0, from: govAddr }
            ));
        });
    });
});