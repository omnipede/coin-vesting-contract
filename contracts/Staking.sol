pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/utils/ReentrancyGuard.sol";
import "./GovChecker.sol";


contract Staking is GovChecker, ReentrancyGuard {
    using SafeMath for uint256;

    mapping(address => uint256) public balance;
    
    event Staked(address user, uint256 amount, uint256 total);
    event Unstaked(address user, uint256 amount, uint256 total);

    constructor(address _registry) public {
        setRegistry(_registry);
    }

    function () external payable {
        deposit();
    }

    function deposit() public nonReentrant payable {
        require(msg.value > 0, "Deposit amount should be greater than zero");

        balance[msg.sender] = balance[msg.sender].add(msg.value);

        emit Staked(msg.sender, msg.value, balance[msg.sender]);
    }

    function withdraw(uint256 amount) public nonReentrant payable {
        require(amount <= balance[msg.sender], "Withdraw amount should be equal or less than balance");

        balance[msg.sender] = balance[msg.sender].sub(amount);
        msg.sender.transfer(amount);

        emit Unstaked(msg.sender, amount, balance[msg.sender]);
    }
}