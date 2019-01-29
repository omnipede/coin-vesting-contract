pragma solidity ^0.4.24;

contract EnvConstants {
    bytes32 internal constant BLOCK_PER_NAME = keccak256("blockPer"); 
    uint256 internal constant BLOCK_PER_TYPE = uint256(VariableTypes.Uint);
    enum VariableTypes {
        Invalid,
        Int,
        Uint,
        Address,
        Bytes32,
        Bytes,
        String
    }
}