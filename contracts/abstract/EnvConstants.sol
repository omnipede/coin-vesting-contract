pragma solidity ^0.4.24;

contract EnvConstants {
    bytes32 internal constant BLOCK_PER_NAME = keccak256("blockPer"); 
    uint256 internal constant BLOCK_PER_TYPE = uint256(VariableTypes.Uint);

    bytes32 internal constant BALLOT_DURATION_MIN_NAME = keccak256("ballotDurationMin"); 
    uint256 internal constant BALLOT_DURATION_MIN_TYPE = uint256(VariableTypes.Uint);

    bytes32 internal constant BALLOT_DURATION_MAX_NAME = keccak256("ballotDurationMax"); 
    uint256 internal constant BALLOT_DURATION_MAX_TYPE = uint256(VariableTypes.Uint);

    bytes32 internal constant STAKING_MIN_NAME = keccak256("stakingMin"); 
    uint256 internal constant STAKING_MIN_TYPE = uint256(VariableTypes.Uint);

    bytes32 internal constant STAKING_MAX_NAME = keccak256("stakingMax"); 
    uint256 internal constant STAKING_MAX_TYPE = uint256(VariableTypes.Uint);

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