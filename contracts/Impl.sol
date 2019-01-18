pragma solidity ^0.4.24;

import "./GovChecker.sol";


contract Impl is GovChecker {
    address internal implementation;

    event ImplementationChanged(
      address indexed previousImpl,
      address indexed newImpl
    );
    
    function getImplementation() public view returns (address) {
        return implementation;
    }

    constructor (address _implAddress) public {
        require(_implAddress != address(0), "Invalid Address");
        implementation = _implAddress;
    }
    
    /**
    * @dev Allows the current Governance Contract to Change Implementation contract to a newImpl.
    * @param newOwner The address to implement to.
    */
    function ChangeImpl(address newImpl) public onlyGov {
        _transferOwnership(newImpl);
    }

    /**
    * @dev Implementation contract to a newImpl.
    * @param newImpl The address to implement to.
    */
    function _ChangeImpl(address newImpl) internal {
        require(newImpl != address(0), "Invalid Adddress");
        emit ImplementationChanged(implementation, newImpl);
        implementation = newImpl;
    }
}