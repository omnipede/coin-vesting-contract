pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/utils/ReentrancyGuard.sol";
import "./abstract/BallotEnums.sol";
import "./storage/BallotStorage.sol";
import "./Gov.sol";
import "./Staking.sol";


contract GovImp is Gov, ReentrancyGuard, BallotEnums {
    using SafeMath for uint256;

    event MemberAdded(address indexed addr, bytes enode);

    function getMinVotingDuration() public pure returns (uint256) { return 1 days; }
    function getMaxVotingDuration() public pure returns (uint256) { return 7 days; }
    function getThreshould() public pure returns (uint256) { return 51; } // 51% from 50 of 100
    
    function getBallotStorageAddress() private view returns (address) {
        return REG.getContractAddress("BallotStorage");
    }
    
    function addProposalToAddMember(
        address member,
        bytes enode,
        bytes ip,
        uint port
        // uint256 lockAmount
    )
        external
        onlyGovMem
        nonReentrant
        returns (uint256 ballotIdx)
    {
        require(msg.sender != member, "Cannot add self");
        require(!isMember(member), "Already member");

        // address ballotStorage = getBallotStorageAddress();
        require(getBallotStorageAddress() != address(0), "BallotStorage NOT FOUND");

        ballotIdx = ballotLength.add(1);
        BallotStorage(getBallotStorageAddress()).createBallotForMemeber(
            ballotIdx, // ballot id
            uint256(BallotTypes.MemberAdd), // ballot type
            msg.sender, // creator
            address(0), // old member address
            member, // new member address
            enode, // new enode
            ip, // new ip
            port // new port
        );
        ballotLength = ballotIdx;
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
        require(getMemberLength() > 1, "Cannot remove a sole member");

        address ballotStorage = getBallotStorageAddress();
        require(ballotStorage != address(0), "BallotStorage NOT FOUND");

        ballotIdx = ballotLength.add(1);
        BallotStorage(ballotStorage).createBallotForMemeber(
            ballotIdx, // ballot id
            uint256(BallotTypes.MemberRemoval), // ballot type
            msg.sender, // creator
            member, // old member address
            address(0), // new member address
            new bytes(0), // new enode
            new bytes(0), // new ip
            0 // new port
        );
        ballotLength = ballotIdx;
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

        ballotIdx = ballotLength.add(1);
        BallotStorage(ballotStorage).createBallotForMemeber(
            ballotIdx, // ballot id
            uint256(BallotTypes.MemberChange), // ballot type
            msg.sender, // creator
            target, // old member address
            nMember, // new member address
            nEnode, // new enode
            nIp, // new ip
            nPort // new port
        );
        ballotLength = ballotIdx;
    }

    function addProposalToChangeGov(
        address newGovAddr
    )
        external
        onlyGovMem
        nonReentrant
        returns (uint256 ballotIdx)
    {
        require(newGovAddr != implementation(), "Same contract address");
        address ballotStorage = getBallotStorageAddress();
        require(ballotStorage != address(0), "BallotStorage NOT FOUND");

        ballotIdx = ballotLength.add(1);
        BallotStorage(ballotStorage).createBallotForAddress(
            ballotLength.add(1), // ballot id
            uint256(BallotTypes.GovernanceChange), // ballot type
            msg.sender, // creator
            newGovAddr // new governance address
        );
        ballotLength = ballotIdx;
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

        ballotIdx = ballotLength.add(1);
        BallotStorage(ballotStorage).createBallotForVariable(
            ballotIdx, // ballot id
            uint256(BallotTypes.EnvValChange), // ballot type
            msg.sender, // creator
            envName, // env name
            envType, // env type
            envVal // env value
        );
        ballotLength = ballotIdx;
    }

    function vote(uint256 ballotIdx, bool approval) external onlyGovMem nonReentrant {
        address ballotStorage = getBallotStorageAddress();
        require(ballotStorage != address(0), "BallotStorage NOT FOUND");

        // Check if some ballot is in progress
        if (ballotInVoting != 0) {
            (uint256 ballotType, uint256 state, ) = BallotStorage(ballotStorage).getBallotState(ballotInVoting);
            (, uint256 endTime, ) = BallotStorage(ballotStorage).getBallotPeriod(ballotInVoting);
            if (state == uint256(BallotStates.InProgress)) {
                if (endTime < block.timestamp) {
                    revert("Now in voting with different ballot");
                } else {
                    BallotStorage(ballotStorage).finalizeBallot(ballotIdx, uint256(BallotStates.Rejected));
                    ballotInVoting = 0;
                }
            }
        }

        // Check if the ballot can be voted
        (ballotType, state, ) = BallotStorage(ballotStorage).getBallotState(ballotIdx);
        if (state == uint256(BallotStates.Ready)) {
            (,, uint256 duration) = BallotStorage(ballotStorage).getBallotPeriod(ballotIdx);
            if (duration < getMinVotingDuration()) {
                BallotStorage(ballotStorage).startBallot(ballotIdx, block.timestamp, block.timestamp + getMinVotingDuration());
            } else if (getMaxVotingDuration() < duration) {
                BallotStorage(ballotStorage).startBallot(ballotIdx, block.timestamp, block.timestamp + getMaxVotingDuration());
            } else {
                BallotStorage(ballotStorage).startBallot(ballotIdx, block.timestamp, block.timestamp + duration);
            }
            ballotInVoting = ballotIdx;
        } else if (state == uint256(BallotStates.InProgress)) {
            // Nothing to do
        } else {
            revert("Expired");
        }

        address staking = REG.getContractAddress("Staking");
        require(staking != address(0), "Staking NOT FOUND");

        // Vote
        uint256 voteIdx = voteLength.add(1);
        if (approval) {
            BallotStorage(ballotStorage).createVote(
                voteIdx,
                ballotIdx,
                msg.sender,
                uint256(DecisionTypes.Accept),
                Staking(staking).calcVotingWeight(msg.sender)
            );
        } else {
            BallotStorage(ballotStorage).createVote(
                voteIdx,
                ballotIdx,
                msg.sender,
                uint256(DecisionTypes.Reject),
                Staking(staking).calcVotingWeight(msg.sender)
            );
        }
        voteLength = voteIdx;

        // Finalize
        (, uint256 accept, uint256 reject) = BallotStorage(ballotStorage).getBallotVotingInfo(ballotIdx);
        if (accept.add(reject) >= getThreshould()) {
            if (accept > reject) {
                if (ballotType == uint256(BallotTypes.MemberAdd)) {
                    addMember(ballotIdx);
                } else if (ballotType == uint256(BallotTypes.MemberRemoval)) {
                } else if (ballotType == uint256(BallotTypes.MemberChange)) {
                } else if (ballotType == uint256(BallotTypes.GovernanceChange)) {
                } else if (ballotType == uint256(BallotTypes.EnvValChange)) {
                }
                BallotStorage(ballotStorage).finalizeBallot(ballotIdx, uint256(BallotStates.Accepted));
            } else {
                BallotStorage(ballotStorage).finalizeBallot(ballotIdx, uint256(BallotStates.Rejected));
            }
            ballotInVoting = 0;
        }
    }

    function addMember(uint256 ballotIdx) private {
        address ballotStorage = getBallotStorageAddress();
        (uint256 ballotType, uint256 state, ) = BallotStorage(ballotStorage).getBallotState(ballotIdx);
        require(ballotType == uint256(BallotTypes.MemberAdd), "Not voting for addMember");
        require(state == uint(BallotStates.InProgress), "Invalid voting state");

        (,, address addr, bytes memory enode, bytes memory ip, uint port) = BallotStorage(ballotStorage).getBallotMember(ballotIdx);
        require(!isMember(addr), "Already member");

        // Lock
        Staking staking = Staking(REG.getContractAddress("Staking"));
        // FIXME: should lock with amount given
        require(staking.availableBalance(addr) >= 100 ether, "Insufficient staking");
        staking.lock(addr, 100 ether);

        // Add member
        uint256 nMemIdx = memberLength.add(1);
        members[nMemIdx] = addr;
        memberIdx[addr] = nMemIdx;

        // Add node
        uint256 nNodeIdx = nodeLength.add(1);
        Node storage node = nodes[nNodeIdx];
        node.enode = enode;
        node.ip = ip;
        node.port = port;
        nodeIdxFromMember[addr] = nNodeIdx;
        nodeToMember[nNodeIdx] = addr;

        memberLength = nMemIdx;
        nodeLength = nNodeIdx;

        emit MemberAdded(addr, enode);
    }

    // function removeMember(address addr) private {}
    // function changeMember(address target, address nAddr, bytes nEnode, bytes nIp, uint nPort) private {}
    // function applyEnv(bytes32 envName, uint256 envType, string envVal) private {}
}