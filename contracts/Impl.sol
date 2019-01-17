pragma solidity ^0.4.24;

contract Impl {
    address internal implementation;
    function getImplementation() public view returns (address){
        return implementation;
    }
    constructor (address _implAddress) public{
        require(_implAddress != address(0), "Invalid Address");
        implementation = _implAddress;
    }
}