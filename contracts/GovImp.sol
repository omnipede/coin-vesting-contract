pragma solidity ^0.4.24;

import "./Gov.sol";
import "./GovChecker.sol";

contract GovImp is Gov, GovChecker {
    bytes32 internal constant OWNER = keccak256("owner");
    bytes32 internal constant OWNER2 = keccak256("owner");

}