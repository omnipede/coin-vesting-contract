pragma solidity ^0.4.24;

import "./EternalStorage.sol";


contract EnvStorageImp is EternalStorage {
    bytes32 internal constant OWNER = keccak256("owner");

}