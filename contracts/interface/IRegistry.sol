pragma solidity ^0.4.16;


interface IRegistry {
    function getContractAddress(bytes32) external view returns (address);
}