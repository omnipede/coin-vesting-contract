pragma solidity ^0.4.24;


contract EnumVotingTypes {
    enum VotingTypes {
        Invalid,
        AddMember,
        RemoveMember,
        ChangeMember,
        ChangeGovernance,
        ChangeEnvironment
    }
}