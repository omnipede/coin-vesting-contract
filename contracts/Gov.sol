pragma solidity ^0.4.24;

import "./proxy/UpgradeabilityProxy.sol";


contract Gov is UpgradeabilityProxy {
    mapping(int => address) public member;
    uint public memberLength;


    constructor(address implementation) public {
        memberLength = 0;
        setImplementation(implementation);
    }
}