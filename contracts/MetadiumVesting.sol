pragma solidity ^0.4.24;

import "zeppelin-solidity/contracts/token/ERC20/TokenVesting.sol";
import "zeppelin-solidity/contracts/token/ERC20/CoinVesting.sol";


/**
 * @title MetadiumVesting
 * @dev A token holder contract that can release its token balance gradually like a
 * typical vesting scheme, with a cliff and vesting period. Optionally revocable by the
 * owner.
 */
contract MetadiumVesting is CoinVesting {
    function MetadiumVesting(address _beneficiary, uint256 _start, uint256 _cliff, uint256 _duration, bool _revocable) public
    CoinVesting(_beneficiary, _start, _cliff, _duration, _revocable)
    {

    }
}
