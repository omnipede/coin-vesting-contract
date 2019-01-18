pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./Registry.sol";


/**
 * @title GovChecker
 * @dev GovChecker Contract that uses Registry contract
 */
contract GovChecker is Ownable {

    Registry public REG;
    bytes32 public GOV_NAME ="GovernanceContract";

    /**
     * @dev Function to set registry address. Contract that wants to use registry should setRegistry first.
     * @param _addr address of registry
     * @return A boolean that indicates if the operation was successful.
     */
    function setRegistry(address _addr) public onlyOwner {
        REG = Registry(_addr);
    }
    
    modifier onlyGov() {
        require(REG.getContractAddress(GOV_NAME) == msg.sender, "No Permission");
        _;
    }

    modifier onlyGovMem() {
        // TODO: need to update
        // require(isPermitted(msg.sender), "No Permission");
        require(false, "No Permission");
        _;
    }

}