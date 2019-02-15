pragma solidity ^0.4.18;

import "zeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol";
import "zeppelin-solidity/contracts/token/ERC20/SafeERC20.sol";
import "zeppelin-solidity/contracts/ownership/Ownable.sol";
import "zeppelin-solidity/contracts/math/SafeMath.sol";

import "zeppelin-solidity/contracts/ReentrancyGuard.sol";


/**
 * @title TokenVesting
 * @dev A token holder contract that can release its token balance gradually like a
 * typical vesting scheme, with a cliff and vesting period. Optionally revocable by the
 * owner.
 */
 contract CoinVesting is Ownable, ReentrancyGuard {
   using SafeMath for uint256;

   event Released(uint256 amount);
   event Revoked();

   // beneficiary of tokens after they are released
   address public beneficiary;

   uint256 public cliff;
   uint256 public start;
   uint256 public duration;

   bool public revocable;

   uint256 public released = 0;
   bool public revoked = false;

   /**
    * @dev Creates a vesting contract that vests its balance of coin to the
    * _beneficiary, gradually in a linear fashion until _start + _duration. By then all
    * of the balance will have vested.
    * @param _beneficiary address of the beneficiary to whom vested tokens are transferred
    * @param _cliff duration in seconds of the cliff in which tokens will begin to vest
    * @param _duration duration in seconds of the period in which the tokens will vest
    * @param _revocable whether the vesting is revocable or not
    */
   function CoinVesting(address _beneficiary, uint256 _start, uint256 _cliff, uint256 _duration, bool _revocable) public {
     require(_beneficiary != address(0));
     require(_cliff <= _duration);

     require(_duration > 0);
     require(_start.add(_duration) > now);

     beneficiary = _beneficiary;
     revocable = _revocable;
     duration = _duration;
     cliff = _start.add(_cliff);
     start = _start;
   }

   /**
    * @notice fallback function
    */
   function () payable nonReentrant public {

   }

   /**
    * @notice Transfers vested coins to beneficiary.
    */
   function release() public {
     uint256 unreleased = releasableAmount();

     require(unreleased > 0);

     released = released.add(unreleased);

     beneficiary.transfer(unreleased);

     Released(unreleased);
   }

   /**
    * @notice Allows the owner to revoke the vesting. Coins already vested
    * remain in the contract, the rest are returned to the owner.
    */
   function revoke() public onlyOwner {
     require(revocable);
     require(!revoked);

     uint256 balance = address(this).balance;

     uint256 unreleased = releasableAmount();
     uint256 refund = balance.sub(unreleased);

     revoked = true;

     require(refund > 0);
     owner.transfer(refund);

     Revoked();
   }

   /**
    * @dev Calculates the amount that has already vested but hasn't been released yet.
    */
   function releasableAmount() public view returns (uint256) {

     return vestedAmount().sub(released);
   }

   /**
    * @dev Calculates the amount that has already vested.
    */
   function vestedAmount() public view returns (uint256) {

     uint256 currentBalance = address(this).balance;
     uint256 totalBalance = currentBalance.add(released);

     if (now < cliff) {
         return 0;
     } else if (now >= start.add(duration) || revoked) {
         return totalBalance;
     } else {
         return totalBalance.mul(now.sub(start)).div(duration);
     }
   }
 }
