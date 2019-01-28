pragma solidity ^0.4.24;

import "./AEnvStorage.sol";
import "./EnumVariableTypes.sol";

contract EnvStorageImp is AEnvStorage,EnumVariableTypes {
    bytes32 internal constant BLOCK_PER_NAME = keccak256("blockPer"); 
    uint256 internal constant BLOCK_PER_TYPE = uint256(VariableTypes.Uint);

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