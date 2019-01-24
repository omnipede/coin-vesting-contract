pragma solidity ^0.4.24;

import "./proxy/UpgradeabilityProxy.sol";
import "./GovChecker.sol";


contract Gov is UpgradeabilityProxy, GovChecker {
    mapping(int => address) public member;
    uint public memberLength;

    constructor(address registry, address implementation) public {
        memberLength = 0;
        setRegistry(registry);
        setImplementation(implementation);
        // bool ret = implementation.delegatecall(bytes4(keccak256("setRegistry(address)")), registry);
        // if (!ret) revert();
    }
}