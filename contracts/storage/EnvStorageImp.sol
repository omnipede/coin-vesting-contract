pragma solidity ^0.4.24;

import "./EternalStorage.sol";
import "../GovChecker.sol";


contract EnvStorageImp is EternalStorage, GovChecker {
    bytes32 internal constant OWNER = keccak256("owner");

}