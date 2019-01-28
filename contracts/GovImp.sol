pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/utils/ReentrancyGuard.sol";
import "./Gov.sol";
import "./abstract/VotingTypes.sol";
import "./storage/BallotStorage.sol";


contract GovImp is Gov, ReentrancyGuard, EnumVotingTypes {
    bytes32 internal constant BLOCK_PER = keccak256("blockPer");
    bytes32 internal constant THRESHOLD = keccak256("threshold");

    function addProposalForAddMember() external onlyGovMem nonReentrant returns (bool) {
        return true;
    }

    function addProposalForSubMember() external onlyGovMem nonReentrant returns (bool) {}
    function addProposalForReplaceMember() external onlyGovMem nonReentrant returns (bool) {}

    function vote() external onlyGovMem nonReentrant returns (bool) {
        return true;
    }

    // function addMember(address addr, bytes enode, bytes ip, uint port) private {}
    // function subMember(address addr) private {}
    // function replaceMember(address target, address nAddr, bytes nEnode, bytes nIp, uint nPort) private {}
}