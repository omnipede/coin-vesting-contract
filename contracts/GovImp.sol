pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/utils/ReentrancyGuard.sol";
import "./Gov.sol";
import "./abstract/VotingTypes.sol";
import "./abstract/BallotEnums.sol";
import "./storage/BallotStorage.sol";


contract GovImp is Gov, ReentrancyGuard, EnumVotingTypes, BallotEnums {
    using SafeMath for uint256;

    bytes32 internal constant BLOCK_PER = keccak256("blockPer");
    bytes32 internal constant THRESHOLD = keccak256("threshold");

    function getBallotStorageAddress() private view returns (address) {
        return REG.getContractAddress("BallotStorage");
    }

    function addProposalForAddMember(
        address member,
        bytes enode,
        bytes ip,
        uint port,
        bytes memo
    )
        external
        onlyGovMem
        nonReentrant
        returns (uint256 ballotIdx)
    {
        require(msg.sender != member, "Cannot add self");
        require(memberIdx[member] == 0, "Already member");

        address ballotStorage = getBallotStorageAddress();
        require(ballotStorage != address(0), "BallotStorage NOT FOUND");
        ballotLength = ballotLength.add(1);
        // BallotStorage(ballotStorage).createBallotForMemeber(
        //     ballotLength, // ballot id
        //     VotingTypes.AddMember, // ballot type
        //     msg.sender, // creator
        //     memo, // memo
        //     address(0), // old member address
        //     member, // new member address
        //     enode, // new enode
        //     ip, // new ip
        //     port // new port
        // );
        return ballotLength;
    }

    function addProposalForSubMember(address member, bytes memo) external onlyGovMem nonReentrant returns (uint256 ballotIdx) {
        address ballotStorage = getBallotStorageAddress();
        require(ballotStorage != address(0), "BallotStorage NOT FOUND");

        ballotLength = ballotLength.add(1);
        // BallotStorage(ballotStorage).createBallotForMemeber(
        //     ballotLength, // ballot id
        //     VotingTypes.SubMember, // ballot type
        //     msg.sender, // creator
        //     memo, // memo
        //     member, // old member address
        //     address(0), // new member address
        //     0, // new enode
        //     0, // new ip
        //     0 // new port
        // );
        return ballotLength;
    }

    function addProposalForReplaceMember(
        address target,
        address nMember,
        bytes nEnode,
        bytes nIp,
        uint nPort,
        bytes memo
    )
        external
        onlyGovMem
        nonReentrant
        returns (uint256 ballotIdx)
    {
        address ballotStorage = getBallotStorageAddress();
        require(ballotStorage != address(0), "BallotStorage NOT FOUND");

        ballotLength = ballotLength.add(1);
        // BallotStorage(ballotStorage).createBallotForMemeber(
        //     ballotLength, // ballot id
        //     VotingTypes.ReplaceMember, // ballot type
        //     msg.sender, // creator
        //     memo, // memo
        //     target, // old member address
        //     nMember, // new member address
        //     nEnode, // new enode
        //     nIp, // new ip
        //     nPort // new port
        // );
        return ballotLength;
    }

    function vote(uint256 ballotIdx, bool approval) external onlyGovMem nonReentrant {}

    // function addMember(address addr, bytes enode, bytes ip, uint port) private {}
    // function subMember(address addr) private {}
    // function replaceMember(address target, address nAddr, bytes nEnode, bytes nIp, uint nPort) private {}
}