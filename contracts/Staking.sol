pragma solidity ^0.4.24;

import "./GovChecker.sol";


contract Staking is GovChecker {
    mapping(address => uint256) public balance;
    
    function () payable public {}
    function withdraw() payable public {}
}