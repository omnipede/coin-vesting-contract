pragma solidity ^0.4.24;

import "./proxy/UpgradeabilityProxy.sol";


contract Gov is UpgradeabilityProxy {
    constructor(address implementation) public {
        setImplementation(implementation);
    }
}