pragma solidity ^0.4.24;

import "./proxy/UpgradeabilityProxy.sol";
import "./GovChecker.sol";


contract Gov is UpgradeabilityProxy, GovChecker {
    bool private initialized;

    mapping(int => address) public member;
    uint public memberLength;

    constructor() {
        initialized = false;
        memberLength = 0;
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