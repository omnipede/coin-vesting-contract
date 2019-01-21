pragma solidity ^0.4.24;

import "./GovChecker.sol";


contract Staking is GovChecker {
    mapping(address => uint256) public balance;
    
    event TestEvent();

    constructor(address _registry) public {
        setRegistry(_registry);
    }

    function () external payable {
        deposit();
    }

    function deposit() public payable {
        balance[msg.sender] = msg.value;
        emit TestEvent();
    }

    function withdraw() public payable {}
}