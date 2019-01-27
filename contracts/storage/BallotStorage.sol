pragma solidity ^0.4.24;
//pragma experimental ABIEncoderV2;
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "../GovChecker.sol";
import "./EnumVariableTypes.sol";
import "./BallotEnums.sol";

contract BallotStorage is  GovChecker, EnumVariableTypes, BallotEnums {
    using SafeMath for uint256;
    
    struct BallotBasic {
        //Ballot ID
        uint256 id;
        //시작 시간
        uint256 startTime;
        //종료 시간 
        uint256 endTime;
        // 투표 종류
        uint256 ballotType;
        // 제안자
        address creator;
        // 투표 내용
        string memo;
        //총 투표자수  
        uint256 totalVoters;
        // 진행상태
        uint256 powerOfAccepts;
        // 진행상태
        uint256 powerOfRejects;
        // 상태 
        uint256 state;
        // 완료유무
        bool isFinalized;
        
    }

    //For MemberAdding/MemberRemoval/MemberSwap
    struct BallotMember {
        uint256 id;    
        address oldMemeberAddress;
        address newMemeberAddress;
        bytes newNodeId; // admin.nodeInfo.id is 512 bit public key
        string newNodeIp;
        uint newNodePort;
    }

    //For GovernanceChange 
    struct BallotAddress {
        uint256 id;
        address newGovernanceAddress;
    }

    //For EnvValChange
    struct BallotVariable {
    //Ballot ID
        uint256 id; 
        bytes32 envVariableName;
        uint256 envVariableType;
        string envVariableValue;
    }

    struct Vote{
        uint256  voteId;
        uint256  ballotId;
        address voter;
        uint256 decision;
        uint256 power;
        uint256 time;
    }

    event BallotCreated(
        uint256 indexed ballotId,
        uint256 indexed ballotType,
        address indexed creator
    );
    event Voted(
        uint256 indexed voteid,
        uint256 indexed ballotId,
        address indexed voter,
        uint256 decision       
    );
    event BallotFinalized(
        uint256 indexed ballotId,
        uint256 state
    );
    
    mapping(uint=>BallotBasic) internal ballotBasicMap;
    mapping(uint=>BallotMember) internal ballotMemberMap;
    mapping(uint=>BallotAddress) internal ballotAddressMap;
    mapping(uint=>BallotVariable) internal ballotVariableMap;
    
    mapping(uint=>Vote) internal voteMap;
    mapping(uint=>mapping(address=>bool)) internal hasVotedMap;

    address prevImp;

    modifier onlyValidTime(uint256 _startTime, uint256 _endTime) {
        require(_startTime > 0 && _endTime > 0);
        require(_endTime > _startTime && _startTime > getTime());
        //uint256 diffTime = _endTime.sub(_startTime);
        // require(diffTime > minBallotDuration());
        // require(diffTime <= maxBallotDuration());
        _;
    }
    function getTime() public view returns(uint256) {
        return now;
    }
    constructor(address _registry) public {
        setRegistry(_registry);
    }

    function getBallotBasic(uint256 _id)public view returns(
        uint256 id,
        uint256 startTime,
        uint256 endTime,
        uint256 ballotType,
        address creator,
        string memo,
        uint256 totalVoters,
        uint256 powerOfAccepts,
        uint256 powerOfRejects,
        uint256 state,
        bool isFinalized
    ){
        BallotBasic memory tBallot = ballotBasicMap[_id];
        id = tBallot.id;
        startTime = tBallot.startTime;
        endTime = tBallot.endTime;
        ballotType = tBallot.ballotType;
        creator = tBallot.creator;
        memo = tBallot.memo;
        totalVoters = tBallot.totalVoters;
        powerOfAccepts = tBallot.powerOfAccepts;
        powerOfRejects = tBallot.powerOfRejects;
        state = tBallot.state;
        isFinalized = tBallot.isFinalized;
        
    }
    function getBallotMember(uint256 _id)public view returns(
        uint256 id,
        address oldMemeberAddress,
        address newMemeberAddress,
        bytes newNodeId, // admin.nodeInfo.id is 512 bit public key
        string newNodeIp,
        uint newNodePort
    ){
        BallotMember storage tBallot = ballotMemberMap[_id];
        id=tBallot.id;
        oldMemeberAddress = tBallot.oldMemeberAddress;
        newMemeberAddress = tBallot.newMemeberAddress;
        newNodeId = tBallot.newNodeId;
        newNodeIp = tBallot.newNodeIp;
        newNodePort = tBallot.newNodePort;
    }
    function getBallotAddress(uint256 _id)public view returns(
        uint256 id,
        address newGovernanceAddress
    ){
        BallotAddress storage tBallot = ballotAddressMap[_id];
        id = tBallot.id;
        newGovernanceAddress = tBallot.newGovernanceAddress;
    }
    function getBallotVariable(uint256 _id)public view returns(
        uint256 id,
        bytes32 envVariableName,
        uint256 envVariableType,
        string envVariableValue 
    ){
        BallotVariable storage tBallot = ballotVariableMap[_id];
        id = tBallot.id;
        envVariableName = tBallot.envVariableName;
        envVariableType = tBallot.envVariableType;
        envVariableValue = tBallot.envVariableValue;
    }
    function _createBallot(
        uint256 _id,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _ballotType,
        address _creator,
        string _memo
        
    ) internal returns(uint256){
        require(ballotBasicMap[_id].id != _id , "already existed ballot");
        ballotBasicMap[_id] = BallotBasic( _id, _startTime, _endTime, _ballotType, _creator, _memo, 0, 0, 0, uint256(BallotStates.InProgress), false);
        emit BallotCreated(_id, _ballotType, _creator);
        return _id;
    }
    function _areMemberBallotParamValid(
        uint256 _ballotType,
        address _oldMemeberAddress,
        address _newMemeberAddress,
        bytes _newNodeId, // admin.nodeInfo.id is 512 bit public key
        string _newNodeIp,
        uint _newNodePort
    ) internal pure returns(bool){
        require((_ballotType >= uint256(BallotTypes.MemberAdd)) && (_ballotType <= uint256(BallotTypes.MemberChange)), "Invalid Ballot Type");

        if (_ballotType == uint256(BallotTypes.MemberRemoval)){
            require(_oldMemeberAddress != address(0),"Invalid old member address");
            require(_newMemeberAddress == address(0),"Invalid new member address");
            require(_newNodeId.length == 0, "Invalid new node id");
            require(bytes(_newNodeIp).length == 0, "Invalid new node IP");
            require(_newNodePort == 0, "Invalid new node Port");
        }else {
            require(_newNodeId.length == 64, "Invalid new node id");
            require(bytes(_newNodeIp).length > 0, "Invalid new node IP");
            require(_newNodePort > 0, "Invalid new node Port");
            if (_ballotType == uint256(BallotTypes.MemberAdd)) {
                require(_oldMemeberAddress == address(0),"Invalid old member address");
                require(_newMemeberAddress != address(0),"Invalid new member address");
            }else if (_ballotType == uint256(BallotTypes.MemberChange)){
                require(_oldMemeberAddress != address(0),"Invalid old member address");
                require(_newMemeberAddress != address(0),"Invalid new member address");
            }
        }

        return true;
    }
    //For MemberAdding/MemberRemoval/MemberSwap
    function createBallotForMemeber(
        uint256 _id,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _ballotType,
        address _creator,
        string _memo,
        address _oldMemeberAddress,
        address _newMemeberAddress,
        bytes _newNodeId, // admin.nodeInfo.id is 512 bit public key
        string _newNodeIp,
        uint _newNodePort
    ) public onlyGov returns (uint256) {
        require(
            _areMemberBallotParamValid(_ballotType,_oldMemeberAddress,_newMemeberAddress,_newNodeId,_newNodeIp,_newNodePort),
            "Invalid Parameter"
        );
        uint256 ballotId = _createBallot(_id, _startTime, _endTime, _ballotType, _creator, _memo);
        BallotMember memory newBallot;
        newBallot.id = ballotId;
        newBallot.oldMemeberAddress = _oldMemeberAddress;
        newBallot.newMemeberAddress = _newMemeberAddress;
        newBallot.newNodeId = _newNodeId;
        newBallot.newNodeIp = _newNodeIp;
        newBallot.newNodePort = _newNodePort;
        ballotMemberMap[ballotId] = newBallot;
        return ballotId;
    }

    
    function createBallotForAddress(
        uint256 _id,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _ballotType,
        address _creator,
        string _memo,
        address _newGovernanceAddress
    ) public onlyGov returns (uint256) {
        require(_ballotType == uint256(BallotTypes.GovernanceChange), "Invalid Ballot Type");
        require(_newGovernanceAddress != address(0), "Invalid Parameter");
        
        uint256 ballotId = _createBallot(_id, _startTime, _endTime, _ballotType, _creator, _memo);
        BallotAddress memory newBallot;
        newBallot.id = ballotId;
        newBallot.newGovernanceAddress = _newGovernanceAddress;
        ballotAddressMap[ballotId] = newBallot;
        return ballotId;
    }

    function _areVariableBallotParamValid(
        uint256 _ballotType,
        bytes32 _envVariableName,
        uint256 _envVariableType,
        string _envVariableValue 
    ) internal pure returns(bool){
        require(_ballotType == uint256(BallotTypes.EnvValChange), "Invalid Ballot Type");
        require(_envVariableName.length > 0, "Invalid environment variable name");
        require(_envVariableType >= uint256(VariableTypes.Int), "Invalid environment variable Type");
        require(_envVariableType <= uint256(VariableTypes.String), "Invalid environment variable Type");
        require(bytes(_envVariableValue).length > 0, "Invalid environment variable value");

        return true;
    }

    function createBallotForVariable(
        uint256 _id,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _ballotType,
        address _creator,
        string _memo,
        bytes32 _envVariableName,
        uint256 _envVariableType,
        string _envVariableValue 
    ) public onlyGov returns (uint256) {
        require(
            _areVariableBallotParamValid(_ballotType, _envVariableName, _envVariableType, _envVariableValue),
            "Invalid Parameter"
        );
        uint256 ballotId = _createBallot(_id, _startTime, _endTime, _ballotType, _creator, _memo);
        BallotVariable memory newBallot;
        newBallot.id = ballotId;
        newBallot.envVariableName = _envVariableName;
        newBallot.envVariableType = _envVariableType;
        newBallot.envVariableValue = _envVariableValue;
        ballotVariableMap[ballotId] = newBallot;
        return ballotId;
    }
    function createVote(
        uint256 _voteId,
        uint256 _ballotId,
        address _voter,
        uint256 _decision,
        uint256 _power
    ) public onlyGov returns (uint256) {
        //1. msg.sender가 member
        //2. actionType 범위 
        require((_decision == uint256(DecisionTypes.Accept)) || (_decision <= uint256(DecisionTypes.Reject)), "Invalid decision");
        
        //3. ballotId 존재 하는지 확인 
        require(ballotBasicMap[_ballotId].id == _ballotId, "not existed Ballot");
        //4. voteId 존재 확인
        require(voteMap[_voteId].voteId != _voteId, "already existed voteId");
        //5. 이미 vote 했는지 확인 
        require(!hasVotedMap[_ballotId][_voter], "already voted");

        //1. 생성
        voteMap[_voteId] = Vote(_voteId, _ballotId, _voter, _decision, _power, getTime());
        
        //2. 투표 업데이트 
        _updateBallotForVote(_ballotId, _voter, _decision, _power);

        //3. event 처리 
        emit Voted(_voteId,_ballotId,_voter,_decision);
    }
    function getVote(uint256 _voteId) public view returns (
        uint256 voteId,
        uint256 ballotId,
        address voter,
        uint256 decision,
        uint256 power,
        uint256 time
    ){
        require(voteMap[_voteId].voteId == _voteId, "not existed voteId");
        Vote memory _vote = voteMap[_voteId];
        voteId = _vote.voteId;
        ballotId = _vote.ballotId;
        voter = _vote.voter;
        decision = _vote.decision;
        power = _vote.power;
        time = _vote.time;
    }
    // update ballot 
    function _updateBallotForVote(
        uint256 _ballotId,
        address _voter,
        uint256 _decision,
        uint256 _power
    ) internal {
        // c1. actionType 범위 
        require((_decision == uint256(DecisionTypes.Accept)) || (_decision == uint256(DecisionTypes.Reject)), "Invalid decision");
        // c2. ballotId 존재 하는지 확인 
        require(ballotBasicMap[_ballotId].id == _ballotId, "not existed Ballot");
        // c3. 이미 vote 했는지 확인 
        require(hasVotedMap[_ballotId][_voter] == false, "already voted");

        //1.get ballotBasic
        BallotBasic storage _ballot = ballotBasicMap[_ballotId];
        //2. 투표 여부 등록
        hasVotedMap[_ballotId][_voter] = true;
        //3. update totalVoters
        _ballot.totalVoters = _ballot.totalVoters.add(1);
        //4. Update power of accept/reject
        if (_decision == uint256(DecisionTypes.Accept)){
            _ballot.powerOfAccepts = _ballot.powerOfAccepts.add(_power);
        } else {
            _ballot.powerOfRejects = _ballot.powerOfRejects.add(_power);
        }
    }
    // finalize ballot info.
    function finalizeBallot(uint256 _ballotId,uint256 _ballotState) public onlyGov{
        require(ballotBasicMap[_ballotId].id == _ballotId, "not existed Ballot");
        require(ballotBasicMap[_ballotId].isFinalized == false, "already finalized");
        require((_ballotState == uint256(BallotStates.Accepted)) || (_ballotState == uint256(BallotStates.Rejected)), "Invalid Ballot Type");

        BallotBasic storage _ballot = ballotBasicMap[_ballotId];
        _ballot.state = _ballotState;
        _ballot.isFinalized = true;
        emit BallotFinalized (_ballotId,_ballotState);
    }
    function hasAlreadyVoted(uint56 _ballotId,address _voter) public view returns(bool){
        return hasVotedMap[_ballotId][_voter];
    }
}