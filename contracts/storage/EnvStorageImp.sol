pragma solidity ^0.4.24;

import "../abstract/EnvConstants.sol";
import "./AEnvStorage.sol";


contract EnvStorageImp is AEnvStorage, EnvConstants {
    function initialize() public onlyOwner{
        string memory blockPerVal = getBlockPerValue();
        string memory BallotDurationMin = getBallotDurationMinValue();
        string memory BallotDurationMax = getBallotDurationMaxValue();
        string memory StakingMin = getStakingMinValue();
        string memory StakingMax = getStakingMaxValue();
        if( bytes(blockPerVal).length == 0){
            _set(BLOCK_PER_NAME, BLOCK_PER_TYPE, "1000");
        }
        if( bytes(BallotDurationMin).length == 0){
            _set(BALLOT_DURATION_MIN_NAME, BALLOT_DURATION_MIN_TYPE, "10000");
        }
        if( bytes(BallotDurationMax).length == 0 ){
            _set(BALLOT_DURATION_MAX_NAME, BALLOT_DURATION_MAX_TYPE, "20000");
        }
        if( bytes(StakingMin).length == 0 ){
            _set(STAKING_MIN_NAME, STAKING_MIN_TYPE, "10000000000");
        }
        if( bytes(StakingMax).length == 0 ){
           
            _set(STAKING_MAX_NAME, STAKING_MAX_TYPE, "20000000000");
        }
        
    }
    function getBlockPer() public view returns (uint256 varType, string varVal) {
        varType = getBlockPerType();
        varVal = getBlockPerValue();
    }
    function getBlockPerType() public view returns (uint256) {
        return getType(BLOCK_PER_NAME);
    }
    function getBlockPerValue() public view returns (string) {
        return getValue(BLOCK_PER_NAME);
    }
    function setBlockPer(string _value) public onlyGov { 
        _set(BLOCK_PER_NAME, BLOCK_PER_TYPE, _value);
    }
    
    function getBallotDurationMin() public view returns (uint256 varType, string varVal) {
        varType = getBallotDurationMinType();
        varVal = getBallotDurationMinValue();
    }
    function getBallotDurationMinType() public view returns (uint256) {
        return getType(BALLOT_DURATION_MIN_NAME);
    }
    function getBallotDurationMinValue() public view returns (string) {
        return getValue(BALLOT_DURATION_MIN_NAME);
    }
    function setBallotDurationMin(string _value) public onlyGov { 
        _set(BALLOT_DURATION_MIN_NAME, BALLOT_DURATION_MIN_TYPE, _value);
    }

    function getBallotDurationMax() public view returns (uint256 varType, string varVal) {
        varType = getBallotDurationMaxType();
        varVal = getBallotDurationMaxValue();
    }
    function getBallotDurationMaxType() public view returns (uint256) {
        return getType(BALLOT_DURATION_MAX_NAME);
    }
    function getBallotDurationMaxValue() public view returns (string) {
        return getValue(BALLOT_DURATION_MAX_NAME);
    }
    function setBallotDurationMax(string _value) public onlyGov { 
        _set(BALLOT_DURATION_MAX_NAME, BALLOT_DURATION_MAX_TYPE, _value);
    }

    function getStakingMin() public view returns (uint256 varType, string varVal) {
        varType = getStakingMinType();
        varVal = getStakingMinValue();
    }
    function getStakingMinType() public view returns (uint256) {
        return getType(STAKING_MIN_NAME);
    }
    function getStakingMinValue() public view returns (string) {
        return getValue(STAKING_MIN_NAME);
    }
    function setStakingMin(string _value) public onlyGov { 
        _set(STAKING_MIN_NAME, STAKING_MIN_TYPE, _value);
    }

    function getStakingMax() public view returns (uint256 varType, string varVal) {
        varType = getStakingMaxType();
        varVal = getStakingMaxValue();
    }
    function getStakingMaxType() public view returns (uint256) {
        return getType(STAKING_MAX_NAME);
    }
    function getStakingMaxValue() public view returns (string) {
        return getValue(STAKING_MAX_NAME);
    }
    function setStakingMax(string _value) public onlyGov { 
        _set(STAKING_MAX_NAME, STAKING_MAX_TYPE, _value);
    }


    /**
    * @dev set a value for a string variable.
    * @param _h The keccak256 hash of the variable name
    * @param _t The type of value
    * @param _v The value to be stored
    */
    function _set(bytes32 _h, uint256 _t,string _v) internal {
        require(_t >= uint256(VariableTypes.Int), "Invalid Variable Type");
        require(_t <= uint256(VariableTypes.String), "Invalid Variable Type");
        require(bytes(_v).length > 0, "empty value");
        if(s[_h]._name == "") {
            _add(_h, _t, _v);
        }else{
            _change(_h, _t, _v);
        }
    }
}