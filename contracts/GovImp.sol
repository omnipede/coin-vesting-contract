pragma solidity ^0.4.24;

import "./Gov.sol";
import "./GovChecker.sol";


contract GovImp is Gov, GovChecker {
    bytes32 internal constant BLOCK_PER = keccak256("blockPer");
    bytes32 internal constant THRESHOLD = keccak256("threshold");

    function addProposal() external onlyGovMem returns (bool) {
        return true;
    }
}