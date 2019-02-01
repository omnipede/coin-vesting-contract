pragma solidity ^0.4.16;


interface IEnvStorage {
    function setBlockPer(string) external;
    function setBallotDurationMin(string) external;
    function setBallotDurationMax(string) external;
    function setStakingMin(string) external;
    function setStakingMax(string) external;
}