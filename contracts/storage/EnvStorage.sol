pragma solidity ^0.4.24;

import "./EternalStorage.sol";
import "../proxy/UpgradeabilityProxy.sol";


contract EnvStorage is UpgradeabilityProxy, EternalStorage {
    constructor(address implementation) public {
        setImplementation(implementation);
    }
}