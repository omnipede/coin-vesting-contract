pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "../abstract/EnvConstants.sol";
import "./AEnvStorage.sol";
//import "./Conversion.sol";


contract EnvStorageImp is AEnvStorage, EnvConstants {
    using SafeMath for uint256;
    //using Conversion for string;
    
    function initialize() public onlyOwner {
        uint256 blockPerVal = getBlockPer();
        uint256 ballotDurationMin = getBallotDurationMin();
        uint256 ballotDurationMax = getBallotDurationMax();
        uint256 stakingMin = getStakingMin();
        uint256 stakingMax = getStakingMax();

        if (blockPerVal == 0) {
            setUint(BLOCK_PER_NAME, 1000);
        }
        if (ballotDurationMin == 0) {
            setUint(BALLOT_DURATION_MIN_NAME, 86400);
        }
        if (ballotDurationMax == 0) {
            setUint(BALLOT_DURATION_MAX_NAME, 604800);
        }
        if (stakingMin == 0) {
            setUint(STAKING_MIN_NAME, 4980000 ether);
        }
        if (stakingMax == 0) {
            setUint(STAKING_MAX_NAME, 39840000 ether);
        }
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

    function setTestStringByBytes(bytes _value) public onlyGov { 
        setString(TEST_STRING, string(_value));
    }

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
}