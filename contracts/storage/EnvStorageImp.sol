pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "../abstract/EnvConstants.sol";
import "./AEnvStorage.sol";
//import "./Conversion.sol";


contract EnvStorageImp is AEnvStorage, EnvConstants {
    using SafeMath for uint256;
    //using Conversion for string;
    
    function initialize() public onlyOwner {
        uint256 blockPerVal = getBlockPerValue();
        uint256 ballotDurationMin = getBallotDurationMinValue();
        uint256 ballotDurationMax = getBallotDurationMaxValue();
        uint256 stakingMin = getStakingMinValue();
        uint256 stakingMax = getStakingMaxValue();

        if (blockPerVal == 0) {
            setUint(BLOCK_PER_NAME, 1000);
        }
        if (ballotDurationMin == 0) {
            setUint(BALLOT_DURATION_MIN_NAME, 604800);
        }
        if (ballotDurationMax == 0) {
            setUint(BALLOT_DURATION_MAX_NAME, 604800);
        }
        if (stakingMin == 0) {
            setUint(STAKING_MIN_NAME, 5e24);
        }
        if (stakingMax == 0) {
            setUint(STAKING_MAX_NAME, 5e26);
        }
    }

    function getBlockPerValue() public view returns (uint256) {
        return getUint(BLOCK_PER_NAME);
    }

    function getBallotDurationMinValue() public view returns (uint256) {
        return getUint(BALLOT_DURATION_MIN_NAME);
    }

    function getBallotDurationMaxValue() public view returns (uint256) {
        return getUint(BALLOT_DURATION_MAX_NAME);
    }

    function getStakingMinValue() public view returns (uint256) {
        return getUint(STAKING_MIN_NAME);
    }

    function getStakingMaxValue() public view returns (uint256) {
        return getUint(STAKING_MAX_NAME);
    }

    function getBlockPer() public view returns (uint256) {
        return getUint(BLOCK_PER_NAME);
    }

    function getBallotDurationMin() public view returns (uint256) {
        return getUint(BALLOT_DURATION_MIN_NAME);
    }

    function getBallotDurationMax() public view returns (uint256) {
        return getUint(BALLOT_DURATION_MAX_NAME);
    }

    function getStakingMin() public view returns (uint256) {
        return getUint(STAKING_MIN_NAME);
    }

    function getStakingMax() public view returns (uint256) {
        return getUint(STAKING_MAX_NAME);
    }
    
    function setBlockPer(uint256 _value) public onlyGov { 
        setUint(BLOCK_PER_NAME, _value);
    }

    function setBallotDurationMin(uint256 _value) public onlyGov { 
        setUint(BALLOT_DURATION_MIN_NAME, _value);
    }

    function setBallotDurationMax(uint256 _value) public onlyGov { 
        setUint(BALLOT_DURATION_MAX_NAME, _value);
    }

    function setStakingMin(uint256 _value) public onlyGov { 
        setUint(STAKING_MIN_NAME, _value);
    }

    function setStakingMax(uint256 _value) public onlyGov { 
        setUint(STAKING_MAX_NAME, _value);
    }

    function setBlockPerByBytes(bytes _value) public onlyGov { 
        setBlockPer(toUint(_value));
    }

    function setBallotDurationMinByBytes(bytes _value) public onlyGov { 
        setBallotDurationMin(toUint(_value));
    }

    function setBallotDurationMaxByBytes(bytes _value) public onlyGov { 
        setBallotDurationMax(toUint(_value));
    }

    function setStakingMinByBytes(bytes _value) public onlyGov { 
        setStakingMin(toUint(_value));
    }

    function setStakingMaxByBytes(bytes _value) public onlyGov { 
        setStakingMax(toUint(_value));
    }

    function getTestInt() public view returns (int256) {
        return getInt(TEST_INT);
    }

    function getTestAddress() public view returns (address) {
        return getAddress(TEST_ADDRESS);
    }

    function getTestBytes32() public view returns (bytes32) {
        return getBytes32(TEST_BYTES32);
    }

    function getTestBytes() public view returns (bytes) {
        return getBytes(TEST_BYTES);
    }

    function getTestString() public view returns (string) {
        return getString(TEST_STRING);
    }

    function setTestIntByBytes(bytes _value) public onlyGov { 
        setInt(TEST_INT, toInt(_value));
    }

    function setTestAddressByBytes(bytes _value) public onlyGov { 
        setAddress(TEST_ADDRESS, toAddress(_value));
    }

    function setTestBytes32ByBytes(bytes _value) public onlyGov { 
        setBytes32(TEST_BYTES32, toBytes32(_value));
    }

    function setTestBytesByBytes(bytes _value) public onlyGov { 
        setBytes(TEST_BYTES, _value);
    }
    
    function toString( bytes memory _input ) public pure returns (string memory _output) {
        return string(_input);
        // uint _offst = _input.length;
        // uint size = 32;
        // assembly {
            
        //     let chunk_count
        //     size := mload(add(_input,_offst))
        //     chunk_count := add(div(size,32),1) // chunk_count = size/32 + 1
            
        //     if gt(mod(size,32),0) {
        //         chunk_count := add(chunk_count,1)  // chunk_count++
        //     }
               
        //     for { let index:= 0 }  lt(index , chunk_count){ index := add(index,1) } {
        //         mstore(add(_output,mul(index,32)),mload(add(_input,_offst)))
        //         _offst := sub(_offst,32)           // _offst -= 32
        //     }
        // }
    }

    function intToBytes(int _input) public pure returns (bytes memory _output) {
        _output = new bytes(32);
        assembly {
            mstore(add(_output, 32), _input)
        }
    } 

    function uintToBytes(uint _input) public pure returns (bytes memory _output) {
        _output = new bytes(32);
        assembly {
            mstore(add(_output, 32), _input)
        }
    }

    function addressToBytes(address _input) public pure returns (bytes _output) {
        assembly {
            let m := mload(0x40)
            mstore(add(m, 20), xor(0x140000000000000000000000000000000000000000, _input))
            mstore(0x40, add(m, 52))
            _output := m
        }
    }
    
    function stringToBytes(string memory _input) public pure returns (bytes _output) {
        //_output = bytes(_input);
        _output = abi.encode(_input);
    }

    event testCodeValue(bytes _bytes, string _string);

    function setTestStringByBytes(bytes _value) public onlyGov { 
        emit testCodeValue(_value, string(_value));
        setString(TEST_STRING, string(_value));
    }

    // function getBlockPer() public view returns (uint256 varType, string varVal) {
    //     (varType,varVal) = get(BLOCK_PER_NAME);
    //     // varType = getBlockPerType();
    //     // varVal = getBlockPerValue();
    // }
    // function getBlockPerType() public view returns (uint256) {
    //     return getType(BLOCK_PER_NAME);
    // }
    // function getBlockPerValue() public view returns (string) {
    //     return getValue(BLOCK_PER_NAME);
    // }
    // function setBlockPer(string _value) public onlyGov { 
    //     _set(BLOCK_PER_NAME, BLOCK_PER_TYPE, _value);
    // }
    
    // function getBallotDurationMin() public view returns (uint256 varType, string varVal) {
    //     varType = getBallotDurationMinType();
    //     varVal = getBallotDurationMinValue();
    // }
    // function getBallotDurationMinType() public view returns (uint256) {
    //     return getType(BALLOT_DURATION_MIN_NAME);
    // }
    // function getBallotDurationMinValue() public view returns (string) {
    //     return getValue(BALLOT_DURATION_MIN_NAME);
    // }
    // function setBallotDurationMin(string _value) public onlyGov { 
    //     _set(BALLOT_DURATION_MIN_NAME, BALLOT_DURATION_MIN_TYPE, _value);
    // }

    // function getBallotDurationMax() public view returns (uint256 varType, string varVal) {
    //     varType = getBallotDurationMaxType();
    //     varVal = getBallotDurationMaxValue();
    // }
    // function getBallotDurationMaxType() public view returns (uint256) {
    //     return getType(BALLOT_DURATION_MAX_NAME);
    // }
    // function getBallotDurationMaxValue() public view returns (string) {
    //     return getValue(BALLOT_DURATION_MAX_NAME);
    // }
    // function setBallotDurationMax(string _value) public onlyGov { 
    //     _set(BALLOT_DURATION_MAX_NAME, BALLOT_DURATION_MAX_TYPE, _value);
    // }

    // function getStakingMin() public view returns (uint256 varType, string varVal) {
    //     varType = getStakingMinType();
    //     varVal = getStakingMinValue();
    // }
    // function getStakingMinType() public view returns (uint256) {
    //     return getType(STAKING_MIN_NAME);
    // }
    // function getStakingMinValue() public view returns (string) {
    //     return getValue(STAKING_MIN_NAME);
    // }
    // function setStakingMin(string _value) public onlyGov { 
    //     _set(STAKING_MIN_NAME, STAKING_MIN_TYPE, _value);
    // }

    // function getStakingMax() public view returns (uint256 varType, string varVal) {
    //     varType = getStakingMaxType();
    //     varVal = getStakingMaxValue();
    // }
    // function getStakingMaxType() public view returns (uint256) {
    //     return getType(STAKING_MAX_NAME);
    // }
    // function getStakingMaxValue() public view returns (string) {
    //     return getValue(STAKING_MAX_NAME);
    // }
    // function setStakingMax(string _value) public onlyGov { 
    //     _set(STAKING_MAX_NAME, STAKING_MAX_TYPE, _value);
    // }


    
    // * @dev set a value for a string variable.
    // * @param _h The keccak256 hash of the variable name
    // * @param _t The type of value
    // * @param _v The value to be stored
    
    // function _set(bytes32 _h, uint256 _t,string _v) internal {
    //     require(_t >= uint256(VariableTypes.Int), "Invalid Variable Type");
    //     require(_t <= uint256(VariableTypes.String), "Invalid Variable Type");
    //     require(bytes(_v).length > 0, "empty value");
    //     if(s[_h]._name == "") {
    //         _add(_h, _t, _v);
    //     }else{
    //         _change(_h, _t, _v);
    //     }
    // }

/*
    function parseAddr(string memory _a) internal pure returns (address _parsedAddress) {
        bytes memory tmp = bytes(_a);
        uint160 iaddr = 0;
        uint160 b1;
        uint160 b2;
        for (uint i = 2; i < 2 + 2 * 20; i += 2) {
            iaddr *= 256;
            b1 = uint160(uint8(tmp[i]));
            b2 = uint160(uint8(tmp[i + 1]));
            if ((b1 >= 97) && (b1 <= 102)) {
                b1 -= 87;
            } else if ((b1 >= 65) && (b1 <= 70)) {
                b1 -= 55;
            } else if ((b1 >= 48) && (b1 <= 57)) {
                b1 -= 48;
            }
            if ((b2 >= 97) && (b2 <= 102)) {
                b2 -= 87;
            } else if ((b2 >= 65) && (b2 <= 70)) {
                b2 -= 55;
            } else if ((b2 >= 48) && (b2 <= 57)) {
                b2 -= 48;
            }
            iaddr += (b1 * 16 + b2);
        }
        return address(iaddr);
    }
    
    function safeParseUInt2(string memory _a) public pure returns (uint _parsedInt) {
        bytes memory bresult = bytes(_a);
        uint256 mint = 0;

        for (uint i = 0; i < bresult.length; i++) {
            if ((uint(uint8(bresult[i])) >= 48) && (uint(uint8(bresult[i])) <= 57)) {
                 
                mint = mint.mul(10);
                mint = mint.add(uint(uint8(bresult[i])) - 48);
            } else {
                revert("Non-numeral character encountered in string!");
            }
        }
        return mint;
    }

    function safeParseInt(string memory _a) public pure returns (int _parsedInt) {
        bytes memory bresult = bytes(_a);
        uint mint = 0;
        int pint = 0;
        bool minus = false;
        for (uint i = 0; i < bresult.length; i++) {
            if ((uint(uint8(bresult[i])) >= 48) && (uint(uint8(bresult[i])) <= 57)) {
                mint = mint.mul(10);
                mint = mint.add(uint(uint8(bresult[i])) - 48);
            } else if (uint(uint8(bresult[i])) == 45) {
                require(i == 0 , 'not start with Minus symbol in string!');
                minus = true;
            } else {
                revert("Non-numeral character encountered in string!");
            }
        }
        if(minus){
            uint _max = uint(INT256_MAX).add(1);
            require(mint <= _max, "out of range of int min!");
            if(mint == _max ){
                pint =INT256_MIN;
            }else{
                pint = int(mint) * -1;
            }
        }else{
            require(mint < uint(INT256_MAX), "out of range of int max!");
            pint =int(mint);
        }
        return pint;
    }
*/
// }

    function toBytes32(bytes memory _input) internal pure returns (bytes32 _output) {
        assembly {
            _output := mload(add(_input, 32))
        }
    }

    function toInt(bytes memory _input) internal pure returns (int256 _output) {
        assembly {
            _output := mload(add(_input, 32))
        }
    }

    function toUint(bytes memory _input) internal pure returns (uint256 _output) {
        
        assembly {
            _output := mload(add(_input, 32))
        }
    }

    function toAddress(bytes memory _input) internal pure returns (address _output) {
        assembly {
            _output := mload(add(_input, 20))
        }
    }

    // function toString(bytes memory _input) internal pure returns(string _output){
    //     _output = string(_input);
    // }
    
    function bytes32ToBytes(bytes32 _input) internal pure returns (bytes) {
        bytes memory _output = new bytes(32);
        assembly {
            mstore(add(_output, 32), _input)
            mstore(add(add(_output, 32), 32), add(_input, 32))
        }
        return _output;
    }
}