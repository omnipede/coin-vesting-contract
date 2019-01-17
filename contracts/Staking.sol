pragma solidity ^0.4.24;
import "./GovChecker.sol";
import "./Impl.sol";

contract Staking is  Impl, GovChecker {

    /**
     * @dev Fallback function for delegate call. This function will return whatever the implementaion call returns
     */
    function () public payable onlyGov(){
        address _impl = getImplementation();
        require(_impl != address(0), "Invalid Address");

        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize)

            let result := delegatecall(gas, _impl, ptr, calldatasize, 0, 0)
            let size := returndatasize
            returndatacopy(ptr, 0, size)

            switch result
            case 0 { revert(ptr, size) }
            default { return(ptr, size) }

        }
    }
}