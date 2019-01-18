pragma solidity ^0.4.24;

import "./EternalStorage.sol";


contract BallotsStorage is EternalStorage {
    bytes32 internal constant OWNER = keccak256("owner");
}