pragma solidity ^0.4.24;

import "../GovChecker.sol";

contract AEnvStorage is GovChecker {
    struct Variable {
        bytes32 _name;
        uint256 _type;
        string _value;
    }
   
    event VarableAdded ( 
        bytes32 indexed _name,
        uint256 indexed _type,
        string _value
    );
    event VarableChanged ( 
        bytes32 indexed _name,
        uint256 indexed _type,
        string _value
    );
   
    mapping(bytes32 => Variable) internal s;
 
    /**
    * @dev Add a new variable .
    * @param _h The keccak256 hash of the variable name
    * @param _t The type of value
    * @param _v The value to be stored
    */
    function _add(bytes32 _h, uint256 _t, string _v) internal  {
        require(s[_h]._name == "","not found");
        s[_h] = Variable(_h,_t,_v);
        emit VarableAdded(_h,_t,_v);
    }
    /**
    * @dev Update a new variable .
    * @param _h The keccak256 hash of the variable name
    * @param _t The type of value
    * @param _v The value to be stored
    */
    function _change(bytes32 _h, uint256 _t, string _v) internal {
        require(s[_h]._name == _h,"not found");
        Variable storage v = s[_h];
        v._name = _h;
        v._type = _t;
        v._value = _v;
        emit VarableChanged(_h,_t,_v);

    }
    /**
    * @dev Get the type & value stored of a string variable by the hash name
    * @param _h The keccak256 hash of the variable name
    */
    function get(bytes32 _h) public view returns (uint256 varType, string varVal){
        require(s[_h]._name == _h,"not found");
        return (s[_h]._type, s[_h]._value);
    }
    /**
    * @dev Get the type stored of a string variable by the hash name
    * @param _h The keccak256 hash of the variable name
    */
    function getType(bytes32 _h) public view returns (uint256){
        require(s[_h]._name == _h,"not found");
        return s[_h]._type;
    }
    /**
    * @dev Get the value stored of a string variable by the hash name
    * @param _h The keccak256 hash of the variable name
    */
    function getValue(bytes32 _h) public view returns (string){
        require(s[_h]._name == _h,"not found");
        return s[_h]._value;
    }
}