pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/utils/ReentrancyGuard.sol";
import "./abstract/BallotEnums.sol";
import "./storage/BallotStorage.sol";
import "./Gov.sol";
import "./Staking.sol";


contract GovImp is Gov, ReentrancyGuard, BallotEnums {
    using SafeMath for uint256;

    event MemberAdded(address indexed addr);
    event MemberRemoved(address indexed addr);
    event MemberChanged(address indexed oldAddr, address indexed newAddr);
    event EnvChanged(bytes32 envName, uint256 envType, string envVal);

    // FIXME: get from EnvStorage
    function getMinStaking() public pure returns (uint256) { return 10 ether; }
    function getMaxStaking() public pure returns (uint256) { return 100 ether; }
    function getMinVotingDuration() public pure returns (uint256) { return 1 days; }
    function getMaxVotingDuration() public pure returns (uint256) { return 7 days; }

    function getThreshould() public pure returns (uint256) { return 51; } // 51% from 51 of 100
    function getBallotStorageAddress() private view returns (address) {
        return REG.getContractAddress("BallotStorage");
    }
    
    function addProposalToAddMember(
        address member,
        bytes enode,
        bytes ip,
        uint port,
        uint256 lockAmount
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
        BallotStorage(getBallotStorageAddress()).updateBallotMemberLockAmount(ballotIdx, lockAmount);
        ballotLength = ballotIdx;
    }

    function addProposalToRemoveMember(
        address member,
        uint256 lockAmount
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
        BallotStorage(ballotStorage).updateBallotMemberLockAmount(ballotIdx, lockAmount);
        ballotLength = ballotIdx;
    }

    function addProposalToChangeMember(
        address target,
        address nMember,
        bytes nEnode,
        bytes nIp,
        uint nPort,
        uint256 lockAmount
    )
        external
        onlyGovMem
        nonReentrant
        returns (uint256 ballotIdx)
    {
        require(isMember(target), "Non-member");

        // address ballotStorage = getBallotStorageAddress();
        require(getBallotStorageAddress() != address(0), "BallotStorage NOT FOUND");

        ballotIdx = ballotLength.add(1);
        BallotStorage(getBallotStorageAddress()).createBallotForMemeber(
            ballotIdx, // ballot id
            uint256(BallotTypes.MemberChange), // ballot type
            msg.sender, // creator
            target, // old member address
            nMember, // new member address
            nEnode, // new enode
            nIp, // new ip
            nPort // new port
        );
        BallotStorage(getBallotStorageAddress()).updateBallotMemberLockAmount(ballotIdx, lockAmount);
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
        require(newGovAddr != address(0), "Implementation cannot be zero");
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
                    BallotStorage(ballotStorage).finalizeBallot(ballotIdx, uint256(BallotStates.Rejected));
                    ballotInVoting = 0;
                    if (ballotIdx == ballotInVoting) {
                        return;
                    }
                } else if (ballotIdx != ballotInVoting) {
                    revert("Now in voting with different ballot");
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
        if (accept.add(reject) < getThreshould()) {
            return;
        }
        if (accept > reject) {
            if (ballotType == uint256(BallotTypes.MemberAdd)) {
                addMember(ballotIdx);
            } else if (ballotType == uint256(BallotTypes.MemberRemoval)) {
                removeMember(ballotIdx);
            } else if (ballotType == uint256(BallotTypes.MemberChange)) {
                changeMember(ballotIdx);
            } else if (ballotType == uint256(BallotTypes.GovernanceChange)) {
                if (BallotStorage(ballotStorage).getBallotAddress(ballotIdx) != address(0)) {
                    setImplementation(BallotStorage(ballotStorage).getBallotAddress(ballotIdx));
                }
            } else if (ballotType == uint256(BallotTypes.EnvValChange)) {
                applyEnv(ballotIdx);
            }
            BallotStorage(ballotStorage).finalizeBallot(ballotIdx, uint256(BallotStates.Accepted));
        } else {
            BallotStorage(ballotStorage).finalizeBallot(ballotIdx, uint256(BallotStates.Rejected));
        }
        ballotInVoting = 0;
    }

    function addMember(uint256 ballotIdx) private {
        // address ballotStorage = getBallotStorageAddress();
        (uint256 ballotType, uint256 state, ) = BallotStorage(getBallotStorageAddress()).getBallotState(ballotIdx);
        require(ballotType == uint256(BallotTypes.MemberAdd), "Not voting for addMember");
        require(state == uint(BallotStates.InProgress), "Invalid voting state");
        (, uint256 accept, uint256 reject) = BallotStorage(getBallotStorageAddress()).getBallotVotingInfo(ballotIdx);
        require(accept.add(reject) >= getThreshould(), "Not yet finalized");

        (
            ,address addr,
            bytes memory enode,
            bytes memory ip,
            uint port,
            uint256 lockAmount
        ) = BallotStorage(getBallotStorageAddress()).getBallotMember(ballotIdx);
        if (isMember(addr)) {
            return; // Already member. it is abnormal case
        }

        // Lock
        require(getMinStaking() <= lockAmount && lockAmount <= getMaxStaking(), "Invalid lock amount");
        Staking(REG.getContractAddress("Staking")).lock(addr, lockAmount);

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

        emit MemberAdded(addr);
    }

    function removeMember(uint256 ballotIdx) private {
        address ballotStorage = getBallotStorageAddress();
        (uint256 ballotType, uint256 state, ) = BallotStorage(ballotStorage).getBallotState(ballotIdx);
        require(ballotType == uint256(BallotTypes.MemberRemoval), "Not voting for removeMember");
        require(state == uint(BallotStates.InProgress), "Invalid voting state");
        (, uint256 accept, uint256 reject) = BallotStorage(ballotStorage).getBallotVotingInfo(ballotIdx);
        require(accept.add(reject) >= getThreshould(), "Not yet finalized");

        (address addr, , , , , uint256 unlockAmount) = BallotStorage(ballotStorage).getBallotMember(ballotIdx);
        if (!isMember(addr)) {
            return; // Non-member. it is abnormal case
        }

        // Remove member
        if (memberIdx[addr] != memberLength) {
            (members[memberIdx[addr]], members[memberLength]) = (members[memberLength], members[memberIdx[addr]]);
        }
        memberIdx[addr] = 0;
        members[memberLength] = address(0);
        memberLength = memberLength.sub(1);

        // Remove node
        if (nodeIdxFromMember[addr] != nodeLength) {
            Node storage node = nodes[nodeIdxFromMember[addr]];
            node.enode = nodes[nodeLength].enode;
            node.ip = nodes[nodeLength].ip;
            node.port = nodes[nodeLength].port;
        }
        nodeIdxFromMember[addr] = 0;
        nodeToMember[nodeLength] = address(0);
        nodeLength = nodeLength.sub(1);

        // Unlock
        Staking(REG.getContractAddress("Staking")).unlock(addr, unlockAmount);

        emit MemberRemoved(addr);
    }

    function changeMember(uint256 ballotIdx) private {
        // address ballotStorage = getBallotStorageAddress();
        (uint256 ballotType, uint256 state, ) = BallotStorage(getBallotStorageAddress()).getBallotState(ballotIdx);
        require(ballotType == uint256(BallotTypes.MemberChange), "Not voting for changeMember");
        require(state == uint(BallotStates.InProgress), "Invalid voting state");
        (, uint256 accept, uint256 reject) = BallotStorage(getBallotStorageAddress()).getBallotVotingInfo(ballotIdx);
        require(accept.add(reject) >= getThreshould(), "Not yet finalized");
        
        (
            address addr,
            address nAddr,
            bytes memory enode,
            bytes memory ip,
            uint port,
            uint256 lockAmount
        ) = BallotStorage(getBallotStorageAddress()).getBallotMember(ballotIdx);
        if (!isMember(addr)) {
            return; // Non-member. it is abnormal case
        }

        Staking staking = Staking(REG.getContractAddress("Staking"));
        if (addr != nAddr) {
            // Lock
            require(getMinStaking() <= lockAmount && lockAmount <= getMaxStaking(), "Invalid lock amount");
            staking.lock(nAddr, lockAmount);
            // Change member
            members[memberIdx[addr]] = nAddr;
        }

        // Change node
        uint256 nodeIdx = nodeIdxFromMember[addr];
        Node storage node = nodes[nodeIdx];
        node.enode = enode;
        node.ip = ip;
        node.port = port;
        if (addr != nAddr) {
            nodeToMember[nodeIdx] = nAddr;
            nodeIdxFromMember[nAddr] = nodeIdx;
            nodeIdxFromMember[addr] = 0;
            // Unlock
            staking.unlock(addr, lockAmount);

            emit MemberChanged(addr, nAddr);
        }
    }

    function applyEnv(uint256 ballotIdx) private {
        // bytes32 envName, uint256 envType, string envVal
        address ballotStorage = getBallotStorageAddress();
        (uint256 ballotType, uint256 state, ) = BallotStorage(ballotStorage).getBallotState(ballotIdx);
        require(ballotType == uint256(BallotTypes.EnvValChange), "Not voting for applyEnv");
        require(state == uint(BallotStates.InProgress), "Invalid voting state");

    }
}