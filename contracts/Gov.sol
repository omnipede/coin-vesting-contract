pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "./proxy/UpgradeabilityProxy.sol";
import "./GovChecker.sol";


contract Gov is UpgradeabilityProxy, GovChecker {
    using SafeMath for uint256;

    bool private initialized;

    mapping(uint256 => address) private idxToMember;
    mapping(address => uint256) public memberToIdx;
    uint256 public memberLength;

    constructor() {
        initialized = false;
        memberLength = memberLength.add(1);
        idxToMember[memberLength] = msg.sender;
        memberToIdx[msg.sender] = memberLength;
    }

    function init(address registry, address implementation) public onlyOwner {
        require(initialized == false, "Already initialized");
        initialized = true;
        setRegistry(registry);
        setImplementation(implementation);
        // bool ret = implementation.delegatecall(bytes4(keccak256("setRegistry(address)")), registry);
        // if (!ret) revert();
    }
}