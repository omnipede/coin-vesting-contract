pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/utils/ReentrancyGuard.sol";
import "./GovChecker.sol";


contract Staking is GovChecker, ReentrancyGuard {
    using SafeMath for uint256;

    mapping(address => uint256) public balance;
    mapping(address => uint256) public lockedBalance;
    
    event Staked(address user, uint256 amount, uint256 total, uint256 avail);
    event Unstaked(address user, uint256 amount, uint256 total, uint256 avail);
    event Locked(address user, uint256 amount, uint256 total, uint256 avail);
    event Unlocked(address user, uint256 amount, uint256 total, uint256 avail);

    constructor(address _registry) public {
        setRegistry(_registry);
    }

    function () external payable {
        deposit();
    }

    function deposit() public nonReentrant payable {
        require(msg.value > 0, "Deposit amount should be greater than zero");

        balance[msg.sender] = balance[msg.sender].add(msg.value);

        emit Staked(msg.sender, msg.value, balance[msg.sender], availBalance(msg.sender));
    }

    function withdraw(uint256 amount) external nonReentrant payable {
        require(amount <= availBalance(msg.sender), "Withdraw amount should be equal or less than balance");

        balance[msg.sender] = balance[msg.sender].sub(amount);
        msg.sender.transfer(amount);

        emit Unstaked(msg.sender, amount, balance[msg.sender], availBalance(msg.sender));
    }

    function lock(address _addr, uint256 lockAmount) external onlyGov {
        require(balance[_addr] >= lockAmount, "Lock amount should be less than balance");
        require(balance[_addr].sub(lockedBalance[_addr]) >= lockAmount, "Insufficient lockable balance");

        lockedBalance[_addr] = lockedBalance[_addr].add(lockAmount);

        emit Locked(_addr, lockAmount, balance[_addr], availBalance(_addr));
    }

    function unlock(address _addr, uint256 unlockAmount) external onlyGov {
        require(lockedBalance[_addr] >= unlockAmount, "Unlock amount should be less than locked");

        lockedBalance[_addr] = lockedBalance[_addr].sub(unlockAmount);

        emit Unlocked(_addr, unlockAmount, balance[_addr], availBalance(_addr));
    }

    function availBalance(address _addr) public view returns (uint256) {
        return balance[_addr].sub(lockedBalance[_addr]);
    }
}