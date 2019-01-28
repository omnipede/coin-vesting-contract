pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "./proxy/UpgradeabilityProxy.sol";
import "./GovChecker.sol";
import "./Staking.sol";


contract Gov is UpgradeabilityProxy, GovChecker {
    bool private initialized;

    // For member
    mapping(uint256 => address) public members;
    mapping(address => uint256) public memberIdx;
    uint256 public memberLength;

    // For enode
    struct Node {
        bytes enode;
        bytes ip;
        uint port;
    }
    mapping(uint256 => Node) public nodes;
    mapping(address => uint256) public nodeIdxFromMember;
    mapping(uint256 => address) public nodeToMember;
    uint256 public nodeLength;

    // For ballot
    uint256 public ballotLength;

    constructor() public {
        initialized = false;
        memberLength = 0;
        nodeLength = 0;
        ballotLength = 0;
    }

    function init(
        address registry,
        address implementation,
        uint256 lockAmount,
        bytes enode,
        bytes ip,
        uint port
    )
        public onlyOwner
    {
        require(initialized == false, "Already initialized");
        initialized = true;
        setRegistry(registry);
        setImplementation(implementation);

        // Lock
        Staking staking = Staking(REG.getContractAddress("Staking"));
        require(staking.availableBalance(msg.sender) >= lockAmount, "Insufficient staking");
        staking.lock(msg.sender, lockAmount);

        // Add member
        memberLength = 1;
        members[memberLength] = msg.sender;
        memberIdx[msg.sender] = memberLength;

        // Add node
        nodeLength = 1;
        Node storage node = nodes[nodeLength];
        node.enode = enode;
        node.ip = ip;
        node.port = port;
        nodeIdxFromMember[msg.sender] = nodeLength;
        nodeToMember[nodeLength] = msg.sender;
    }
}