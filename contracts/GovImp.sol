pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/utils/ReentrancyGuard.sol";
import "./abstract/BallotEnums.sol";
import "./storage/BallotStorage.sol";
import "./Gov.sol";
import "./Staking.sol";


contract GovImp is Gov, ReentrancyGuard, BallotEnums {
    using SafeMath for uint256;

    bytes32 internal constant BLOCK_PER = keccak256("blockPer");
    bytes32 internal constant THRESHOLD = keccak256("threshold");

    function getBallotStorageAddress() private view returns (address) {
        return REG.getContractAddress("BallotStorage");
    }

    function getMaxVotingDuration() public pure returns (uint256) {
        return 7 days;
    }

    function addProposalToAddMember(
        address member,
        bytes enode,
        bytes ip,
        uint port
    )
        external
        onlyGovMem
        nonReentrant
        returns (uint256 ballotIdx)
    {
        require(msg.sender != member, "Cannot add self");
        require(!isMember(member), "Already member");

        address ballotStorage = getBallotStorageAddress();
        require(ballotStorage != address(0), "BallotStorage NOT FOUND");

        BallotStorage(ballotStorage).createBallotForMemeber(
            ballotLength.add(1), // ballot id
            uint256(BallotTypes.MemberAdd), // ballot type
            msg.sender, // creator
            address(0), // old member address
            member, // new member address
            enode, // new enode
            ip, // new ip
            port // new port
        );
        ballotLength = ballotLength.add(1);
        return ballotLength;
    }

    function addProposalToRemoveMember(
        address member
    )
        external
        onlyGovMem
        nonReentrant
        returns (uint256 ballotIdx)
    {
        require(isMember(member), "Non-member");

        address ballotStorage = getBallotStorageAddress();
        require(ballotStorage != address(0), "BallotStorage NOT FOUND");

        BallotStorage(ballotStorage).createBallotForMemeber(
            ballotLength.add(1), // ballot id
            uint256(BallotTypes.MemberRemoval), // ballot type
            msg.sender, // creator
            member, // old member address
            address(0), // new member address
            new bytes(0), // new enode
            new bytes(0), // new ip
            0 // new port
        );
        ballotLength = ballotLength.add(1);
        return ballotLength;
    }

    function addProposalToChangeMember(
        address target,
        address nMember,
        bytes nEnode,
        bytes nIp,
        uint nPort
    )
        external
        onlyGovMem
        nonReentrant
        returns (uint256 ballotIdx)
    {
        require(isMember(target), "Non-member");

        address ballotStorage = getBallotStorageAddress();
        require(ballotStorage != address(0), "BallotStorage NOT FOUND");

        BallotStorage(ballotStorage).createBallotForMemeber(
            ballotLength.add(1), // ballot id
            uint256(BallotTypes.MemberChange), // ballot type
            msg.sender, // creator
            target, // old member address
            nMember, // new member address
            nEnode, // new enode
            nIp, // new ip
            nPort // new port
        );
        ballotLength = ballotLength.add(1);
        return ballotLength;
    }

    function addProposalToChangeGov(
        address newGovAddr
    )
        external
        onlyGovMem
        nonReentrant
        returns (uint256 ballotIdx)
    {
        address ballotStorage = getBallotStorageAddress();
        require(ballotStorage != address(0), "BallotStorage NOT FOUND");

        BallotStorage(ballotStorage).createBallotForAddress(
            ballotLength.add(1), // ballot id
            uint256(BallotTypes.GovernanceChange), // ballot type
            msg.sender, // creator
            newGovAddr // new governance address
        );
        ballotLength = ballotLength.add(1);
        return ballotLength;
    }

    function addProposalToChangeEnv(
        bytes32 envName,
        uint256 envType,
        string envVal
    )
        external
        onlyGovMem
        nonReentrant
        returns (uint256 ballotIdx)
    {
        address ballotStorage = getBallotStorageAddress();
        require(ballotStorage != address(0), "BallotStorage NOT FOUND");

        BallotStorage(ballotStorage).createBallotForVariable(
            ballotLength.add(1), // ballot id
            uint256(BallotTypes.EnvValChange), // ballot type
            msg.sender, // creator
            envName, // env name
            envType, // env type
            envVal // env value
        );
        ballotLength = ballotLength.add(1);
        return ballotLength;
    }

    function vote(uint256 ballotIdx, bool approval) external onlyGovMem nonReentrant {
        address ballotStorage = getBallotStorageAddress();
        require(ballotStorage != address(0), "BallotStorage NOT FOUND");

        // Check if some ballot is in progress
        if (ballotInVoting != 0) {
            (, uint256 state, ) = BallotStorage(ballotStorage).getBallotState(ballotIdx);
            (, uint256 endTime, ) = BallotStorage(ballotStorage).getBallotPeriod(ballotIdx);
            if (state == uint256(BallotStates.InProgress)) {
                if (endTime < block.timestamp) {
                    revert("Now in voting with different ballot");
                } else {
                    BallotStorage(ballotStorage).finalizeBallot(ballotIdx, uint256(DecisionTypes.Reject));
                    ballotInVoting = 0;
                }
            }
        }

        // Check if the ballot can be voted
        (, state, ) = BallotStorage(ballotStorage).getBallotState(ballotIdx);
        if (state == uint256(BallotStates.Ready)) {
            BallotStorage(ballotStorage).startBallot(ballotIdx, block.timestamp, block.timestamp + getMaxVotingDuration());
        } else if (state == uint256(BallotStates.InProgress)) {
            // Nothing to do
        } else {
            revert("Expired");
        }

        address staking = REG.getContractAddress("Staking");
        require(staking != address(0), "Staking NOT FOUND");

        // Vote
        if (approval) {
            BallotStorage(ballotStorage).createVote(
                voteLength.add(1),
                ballotIdx,
                msg.sender,
                uint256(DecisionTypes.Accept),
                Staking(staking).calcVotingWeight(msg.sender)
            );
        } else {
            BallotStorage(ballotStorage).createVote(
                voteLength.add(1),
                ballotIdx,
                msg.sender,
                uint256(DecisionTypes.Reject),
                Staking(staking).calcVotingWeight(msg.sender)
            );
        }
        voteLength = voteLength.add(1);

        // Finalize
    }

    // function addMember(address addr, bytes enode, bytes ip, uint port) private {}
    // function removeMember(address addr) private {}
    // function changeMember(address target, address nAddr, bytes nEnode, bytes nIp, uint nPort) private {}
    // function applyEnv(bytes32 envName, uint256 envType, string envVal) private {}
}