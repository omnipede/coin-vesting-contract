pragma solidity ^0.4.16;


interface IEnvStorage {
    function setBlockPerByBytes(bytes) external;
    function setBallotDurationMinByBytes(bytes) external;
    function setBallotDurationMaxByBytes(bytes) external;
    function setStakingMinByBytes(bytes) external;
    function setStakingMaxByBytes(bytes) external;
}