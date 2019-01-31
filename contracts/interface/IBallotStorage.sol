pragma solidity ^0.4.24;


contract IBallotStorage {
    function getBallotBasic(uint256) public view returns (
        uint256,uint256,uint256,address,bytes,uint256,
        uint256,uint256,uint256,bool,uint256);
    function getBallotMember(uint256) public view returns (address,address,bytes,bytes,uint256,uint256);
    function getBallotAddress(uint256) public view returns (address);
    function getBallotVariable(uint256) public view returns (bytes32,uint256,bytes);
    function createBallotForMemeber(
        uint256,uint256,address,address,
        address,bytes,bytes,uint) public;
    function createBallotForAddress(uint256,uint256,address,address) public returns (uint256);
    function createBallotForVariable(uint256,uint256,address,bytes32,uint256,bytes) public returns (uint256);
    function createVote(uint256,uint256,address,uint256,uint256) public returns (uint256);
    function finalizeBallot(uint256, uint256) public;
    function startBallot(uint256,uint256,uint256) public;
    function updateBallotDuration(uint256,uint256) public;
    function updateBallotMemberLockAmount(uint256,uint256) public;
    function getBallotPeriod(uint256) public view returns (uint256,uint256,uint256);
    function getBallotVotingInfo(uint256) public view returns (uint256,uint256,uint256);
    function getBallotState(uint256) public view returns (uint256,uint256,bool);
}