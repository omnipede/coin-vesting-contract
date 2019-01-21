pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/utils/ReentrancyGuard.sol";
import "./GovChecker.sol";


contract Staking is GovChecker, ReentrancyGuard {
    using SafeMath for uint256;

    mapping(address => uint256) public balance;
    
    event TestEvent();

    constructor(address _registry) public {
        setRegistry(_registry);
    }

    function () external payable {
        deposit();
    }

    function deposit() public nonReentrant payable {
        require(msg.value > 0);
        
        balance[msg.sender] = balance[msg.sender].add(msg.value);
        emit TestEvent();
    }

    function withdraw() public payable {}
}