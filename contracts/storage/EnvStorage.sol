pragma solidity ^0.4.24;

import "./AEnvStorage.sol";
import "../proxy/UpgradeabilityProxy.sol";

contract EnvStorage is UpgradeabilityProxy, AEnvStorage {

    constructor(address _registry, address implementation) public {
        setRegistry(_registry);
        setImplementation(implementation);
    }
}