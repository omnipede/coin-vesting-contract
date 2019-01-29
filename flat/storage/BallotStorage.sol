pragma solidity ^0.4.13;

library SafeMath {

  /**
  * @dev Multiplies two numbers, reverts on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b);

    return c;
  }

  /**
  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  /**
  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  /**
  * @dev Adds two numbers, reverts on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

    return c;
  }

  /**
  * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
  * reverts when dividing by zero.
  */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}

contract Ownable {
  address private _owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() internal {
    _owner = msg.sender;
    emit OwnershipTransferred(address(0), _owner);
  }

  /**
   * @return the address of the owner.
   */
  function owner() public view returns(address) {
    return _owner;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(isOwner());
    _;
  }

  /**
   * @return true if `msg.sender` is the owner of the contract.
   */
  function isOwner() public view returns(bool) {
    return msg.sender == _owner;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0));
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

contract ReentrancyGuard {

  /// @dev counter to allow mutex lock with only one SSTORE operation
  uint256 private _guardCounter;

  constructor() internal {
    // The counter starts at one to prevent changing it from zero to a non-zero
    // value, which is a more expensive operation.
    _guardCounter = 1;
  }

  /**
   * @dev Prevents a contract from calling itself, directly or indirectly.
   * Calling a `nonReentrant` function from another `nonReentrant`
   * function is not supported. It is possible to prevent this from happening
   * by making the `nonReentrant` function external, and make it call a
   * `private` function that does the actual work.
   */
  modifier nonReentrant() {
    _guardCounter += 1;
    uint256 localCounter = _guardCounter;
    _;
    require(localCounter == _guardCounter);
  }

}

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
        address addr = REG.getContractAddress(GOV_NAME);
        require(addr != address(0), "No Governance");
        require(Gov(addr).memberIdx(msg.sender) != 0, "No Permission");
        _;
    }

}

contract Registry is Ownable {
    mapping(bytes32=>address) public contracts;
    mapping(bytes32=>mapping(address=>bool)) public permissions;

    event SetContractDomain(address setter, bytes32 indexed name, address indexed addr);
    event SetPermission(bytes32 indexed _contract, address indexed granted, bool status);

    /**
    * @dev Function to set contract(can be general address) domain
    * Only owner can use this function
    * @param _name name
    * @param _addr address
    * @return A boolean that indicates if the operation was successful.
    */
    function setContractDomain(bytes32 _name, address _addr) public onlyOwner returns (bool success) {
        require(_addr != address(0x0), "address should be non-zero");
        contracts[_name] = _addr;

        emit SetContractDomain(msg.sender, _name, _addr);

        return true;
    }

    /**
    * @dev Function to get contract(can be general address) address
    * Anyone can use this function
    * @param _name _name
    * @return An address of the _name
    */
    function getContractAddress(bytes32 _name) public view returns (address addr) {
        require(contracts[_name] != address(0x0), "address should be non-zero");
        return contracts[_name];
    }
    
    /**
    * @dev Function to set permission on contract
    * contract using modifier 'permissioned' references mapping variable 'permissions'
    * Only owner can use this function
    * @param _contract contract name
    * @param _granted granted address
    * @param _status true = can use, false = cannot use. default is false
    * @return A boolean that indicates if the operation was successful.
    */
    function setPermission(bytes32 _contract, address _granted, bool _status) public onlyOwner returns (bool success) {
        require(_granted != address(0x0), "address should be non-zero");
        permissions[_contract][_granted] = _status;

        emit SetPermission(_contract, _granted, _status);
        
        return true;
    }

    /**
    * @dev Function to get permission on contract
    * contract using modifier 'permissioned' references mapping variable 'permissions'
    * @param _contract contract name
    * @param _granted granted address
    * @return permission result
    */
    function getPermission(bytes32 _contract, address _granted) public view returns (bool found) {
        return permissions[_contract][_granted];
    }
    
}

contract Staking is GovChecker, ReentrancyGuard {
    using SafeMath for uint256;

    mapping(address => uint256) private _balance;
    mapping(address => uint256) private _lockedBalance;
    uint256 private _totalLockedBalance;
    
    event Staked(address indexed payee, uint256 amount, uint256 total, uint256 available);
    event Unstaked(address indexed payee, uint256 amount, uint256 total, uint256 available);
    event Locked(address indexed payee, uint256 amount, uint256 total, uint256 available);
    event Unlocked(address indexed payee, uint256 amount, uint256 total, uint256 available);

    constructor(address _registry) public {
        _totalLockedBalance = 0;
        setRegistry(_registry);
    }

    function balanceOf(address payee) public view returns (uint256) {
        return _balance[payee];
    }

    function lockedBalanceOf(address payee) public view returns (uint256) {
        return _lockedBalance[payee];
    }

    function availableBalance(address payee) public view returns (uint256) {
        return _balance[payee].sub(_lockedBalance[payee]);
    }

    /**
    * @dev Calculate voting weight which range between 0 and 100.
    * @param payee The address whose funds were locked.
    */
    function calcVotingWeight(address payee) public view returns (uint256) {
        return calcVotingWeightWithScaleFactor(payee, 1e2);
    }

    /**
    * @dev Calculate voting weight with a scale factor.
    * @param payee The address whose funds were locked.
    * @param factor The scale factor for weight. For instance:
    *               if 1e1, result range is between 0 ~ 10
    *               if 1e2, result range is between 0 ~ 100
    *               if 1e3, result range is between 0 ~ 1000
    */
    function calcVotingWeightWithScaleFactor(address payee, uint32 factor) public view returns (uint256) {
        if (_lockedBalance[payee] == 0 || factor == 0) return 0;
        return _lockedBalance[payee].mul(factor).div(_totalLockedBalance);
    }

    function () external payable {
        revert();
    }

    /**
    * @dev Deposit from a sender.
    */
    function deposit() external nonReentrant payable {
        require(msg.value > 0, "Deposit amount should be greater than zero");

        _balance[msg.sender] = _balance[msg.sender].add(msg.value);

        emit Staked(msg.sender, msg.value, _balance[msg.sender], availableBalance(msg.sender));
    }

    /**
    * @dev Withdraw for a sender.
    * @param amount The amount of funds will be withdrawn and transferred to.
    */
    function withdraw(uint256 amount) external nonReentrant {
        require(amount <= availableBalance(msg.sender), "Withdraw amount should be equal or less than balance");

        _balance[msg.sender] = _balance[msg.sender].sub(amount);
        msg.sender.transfer(amount);

        emit Unstaked(msg.sender, amount, _balance[msg.sender], availableBalance(msg.sender));
    }

    /**
    * @dev Lock fund
    * @param payee The address whose funds will be locked.
    * @param lockAmount The amount of funds will be locked.
    */
    function lock(address payee, uint256 lockAmount) external onlyGov {
        require(_balance[payee] >= lockAmount, "Lock amount should be equal or less than balance");
        require(availableBalance(payee) >= lockAmount, "Insufficient balance that can be locked");

        _lockedBalance[payee] = _lockedBalance[payee].add(lockAmount);
        _totalLockedBalance = _totalLockedBalance.add(lockAmount);

        emit Locked(payee, lockAmount, _balance[payee], availableBalance(payee));
    }

    /**
    * @dev Unlock fund
    * @param payee The address whose funds will be unlocked.
    * @param unlockAmount The amount of funds will be unlocked.
    */
    function unlock(address payee, uint256 unlockAmount) external onlyGov {
        require(_lockedBalance[payee] >= unlockAmount, "Unlock amount should be equal or less than balance locked");

        _lockedBalance[payee] = _lockedBalance[payee].sub(unlockAmount);
        _totalLockedBalance = _totalLockedBalance.sub(unlockAmount);

        emit Unlocked(payee, unlockAmount, _balance[payee], availableBalance(payee));
    }

}

contract BallotEnums {
    enum BallotStates {
        Invalid,
        Ready,
        InProgress,
        Accepted,
        Rejected
    }

    enum DecisionTypes {
        Invalid,
        Accept,
        Reject
    }

    enum BallotTypes {
        Invalid,
        MemberAdd,  // new Member Address, new Node id, new Node ip, new Node port
        MemberRemoval, // old Member Address
        MemberChange,     // Old Member Address, New Member Address, new Node id, New Node ip, new Node port
        GovernanceChange, // new Governace Impl Address
        EnvValChange    // Env variable name, type , value
    }
}

contract EnumVariableTypes {
    enum VariableTypes {
        Invalid,
        Int,
        Uint,
        Address,
        Bytes32,
        Bytes,
        String
    }
}

contract Proxy {
    /**
    * @dev Fallback function allowing to perform a delegatecall to the given implementation.
    * This function will return whatever the implementation call returns
    */
    function () payable public {
        address _impl = implementation();
        require(_impl != address(0));

        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize)
            let result := delegatecall(gas, _impl, ptr, calldatasize, 0, 0)
            let size := returndatasize
            returndatacopy(ptr, 0, size)

            switch result
            case 0 { revert(ptr, size) }
            default { return(ptr, size) }
        }
    }

    /**
    * @dev Tells the address of the implementation where every call will be delegated.
    * @return address of the implementation to which it will be delegated
    */
    function implementation() public view returns (address);
}

contract UpgradeabilityProxy is Proxy {
    /**
     * @dev This event will be emitted every time the implementation gets upgraded
     * @param implementation representing the address of the upgraded implementation
     */
    event Upgraded(address indexed implementation);

    // Storage position of the address of the current implementation
    bytes32 private constant IMPLEMENT_POSITION = keccak256("org.metadium.proxy.implementation");

    /**
     * @dev Constructor function
     */
    constructor() public {}

    /**
     * @dev Tells the address of the current implementation
     * @return address of the current implementation
     */
    function implementation() public view returns (address impl) {
        bytes32 position = IMPLEMENT_POSITION;
        assembly {
            impl := sload(position)
        }
    }

    /**
     * @dev Sets the address of the current implementation
     * @param newImplementation address representing the new implementation to be set
     */
    function setImplementation(address newImplementation) internal {
        bytes32 position = IMPLEMENT_POSITION;
        assembly {
            sstore(position, newImplementation)
        }
    }

    /**
     * @dev Upgrades the implementation address
     * @param newImplementation representing the address of the new implementation to be set
     */
    function _upgradeTo(address newImplementation) internal {
        address currentImplementation = implementation();
        require(currentImplementation != newImplementation);
        setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }
}

contract Gov is UpgradeabilityProxy, GovChecker {
    bool private initialized;

    // For member
    mapping(uint256 => address) public members;
    mapping(address => uint256) public memberIdx;
    uint256 public memberLength;

    // For enode
    struct Node {
        bytes enode;
        bytes ip;
        uint port;
    }
    mapping(uint256 => Node) public nodes;
    mapping(address => uint256) public nodeIdxFromMember;
    mapping(uint256 => address) public nodeToMember;
    uint256 public nodeLength;

    // For ballot
    uint256 public ballotLength;

    constructor() public {
        initialized = false;
        memberLength = 0;
        nodeLength = 0;
        ballotLength = 0;
    }

    function init(
        address registry,
        address implementation,
        uint256 lockAmount,
        bytes enode,
        bytes ip,
        uint port
    )
        public onlyOwner
    {
        require(initialized == false, "Already initialized");

        setRegistry(registry);
        setImplementation(implementation);

        // Lock
        Staking staking = Staking(REG.getContractAddress("Staking"));
        require(staking.availableBalance(msg.sender) >= lockAmount, "Insufficient staking");
        staking.lock(msg.sender, lockAmount);

        // Add member
        memberLength = 1;
        members[memberLength] = msg.sender;
        memberIdx[msg.sender] = memberLength;

        // Add node
        nodeLength = 1;
        Node storage node = nodes[nodeLength];
        node.enode = enode;
        node.ip = ip;
        node.port = port;
        nodeIdxFromMember[msg.sender] = nodeLength;
        nodeToMember[nodeLength] = msg.sender;

        initialized = true;
    }
}

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
        bytes memo;
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
        bytes newNodeIp;
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
    
    event BallotStarted(
        uint256 indexed ballotId,
        uint256 indexed startTime,
        uint256 indexed endTime
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

    function getBallotBasic(uint256 _id) public view returns (
        uint256 id,
        uint256 startTime,
        uint256 endTime,
        uint256 ballotType,
        address creator,
        bytes memo,
        uint256 totalVoters,
        uint256 powerOfAccepts,
        uint256 powerOfRejects,
        uint256 state,
        bool isFinalized
    )
    {
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

    function getBallotMember(uint256 _id) public view returns (
        uint256 id,
        address oldMemeberAddress,
        address newMemeberAddress,
        bytes newNodeId, // admin.nodeInfo.id is 512 bit public key
        bytes newNodeIp,
        uint newNodePort
    )
    {
        BallotMember storage tBallot = ballotMemberMap[_id];
        id=tBallot.id;
        oldMemeberAddress = tBallot.oldMemeberAddress;
        newMemeberAddress = tBallot.newMemeberAddress;
        newNodeId = tBallot.newNodeId;
        newNodeIp = tBallot.newNodeIp;
        newNodePort = tBallot.newNodePort;
    }

    function getBallotAddress(uint256 _id) public view returns (
        uint256 id,
        address newGovernanceAddress
    )
    {
        BallotAddress storage tBallot = ballotAddressMap[_id];
        id = tBallot.id;
        newGovernanceAddress = tBallot.newGovernanceAddress;
    }

    function getBallotVariable(uint256 _id) public view returns (
        uint256 id,
        bytes32 envVariableName,
        uint256 envVariableType,
        string envVariableValue 
    )
    {
        BallotVariable storage tBallot = ballotVariableMap[_id];
        id = tBallot.id;
        envVariableName = tBallot.envVariableName;
        envVariableType = tBallot.envVariableType;
        envVariableValue = tBallot.envVariableValue;
    }

    function _createBallot(
        uint256 _id,
        // uint256 _startTime,
        // uint256 _endTime,
        uint256 _ballotType,
        address _creator,
        bytes _memo
        
    )
        internal
        returns(uint256)
    {
        require(ballotBasicMap[_id].id != _id , "already existed ballot");
        ballotBasicMap[_id] = BallotBasic( _id, 0, 0, _ballotType, _creator, _memo, 0, 0, 0, uint256(BallotStates.Ready), false);
        emit BallotCreated(_id, _ballotType, _creator);
        return _id;
    }

    function _areMemberBallotParamValid(
        uint256 _ballotType,
        address _oldMemeberAddress,
        address _newMemeberAddress,
        bytes _newNodeId, // admin.nodeInfo.id is 512 bit public key
        bytes _newNodeIp,
        uint _newNodePort
    )
        internal
        pure
        returns(bool)
    {
        require((_ballotType >= uint256(BallotTypes.MemberAdd)) && (_ballotType <= uint256(BallotTypes.MemberChange)), "Invalid Ballot Type");

        if (_ballotType == uint256(BallotTypes.MemberRemoval)){
            require(_oldMemeberAddress != address(0),"Invalid old member address");
            require(_newMemeberAddress == address(0),"Invalid new member address");
            require(_newNodeId.length == 0, "Invalid new node id");
            require(_newNodeIp.length == 0, "Invalid new node IP");
            require(_newNodePort == 0, "Invalid new node Port");
        }else {
            require(_newNodeId.length == 64, "Invalid new node id");
            require(_newNodeIp.length > 0, "Invalid new node IP");
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
        uint256 _ballotType,
        address _creator,
        address _oldMemeberAddress,
        address _newMemeberAddress,
        bytes _newNodeId, // admin.nodeInfo.id is 512 bit public key
        bytes _newNodeIp,
        uint _newNodePort
    )
        public
        onlyGov
        returns (uint256)
    {
        require(
            _areMemberBallotParamValid(_ballotType,_oldMemeberAddress,_newMemeberAddress,_newNodeId,_newNodeIp,_newNodePort),
            "Invalid Parameter"
        );
        uint256 ballotId = _createBallot(_id, _ballotType, _creator, '');
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
        uint256 _ballotType,
        address _creator,
        bytes _memo,
        address _newGovernanceAddress
    )
        public
        onlyGov
        returns (uint256)
    {
        require(_ballotType == uint256(BallotTypes.GovernanceChange), "Invalid Ballot Type");
        require(_newGovernanceAddress != address(0), "Invalid Parameter");
        
        uint256 ballotId = _createBallot(_id, _ballotType, _creator, _memo);
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
    )
        internal
        pure
        returns(bool)
    {
        require(_ballotType == uint256(BallotTypes.EnvValChange), "Invalid Ballot Type");
        require(_envVariableName.length > 0, "Invalid environment variable name");
        require(_envVariableType >= uint256(VariableTypes.Int), "Invalid environment variable Type");
        require(_envVariableType <= uint256(VariableTypes.String), "Invalid environment variable Type");
        require(bytes(_envVariableValue).length > 0, "Invalid environment variable value");

        return true;
    }

    function createBallotForVariable(
        uint256 _id,
        uint256 _ballotType,
        address _creator,
        bytes32 _envVariableName,
        uint256 _envVariableType,
        string _envVariableValue 
    )
        public
        onlyGov
        returns (uint256)
    {
        require(
            _areVariableBallotParamValid(_ballotType, _envVariableName, _envVariableType, _envVariableValue),
            "Invalid Parameter"
        );
        uint256 ballotId = _createBallot(_id, _ballotType, _creator, '');
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
    )
        public
        onlyGov
        returns (uint256)
    {
        //1. msg.sender가 member
        //2. actionType 범위 
        require((_decision == uint256(DecisionTypes.Accept)) || (_decision <= uint256(DecisionTypes.Reject)), "Invalid decision");
        
        //3. ballotId 존재 하는지 확인 
        require(ballotBasicMap[_ballotId].id == _ballotId, "not existed Ballot");
        //4. voteId 존재 확인
        require(voteMap[_voteId].voteId != _voteId, "already existed voteId");
        //5. 이미 vote 했는지 확인 
        require(!hasVotedMap[_ballotId][_voter], "already voted");
        require(ballotBasicMap[_ballotId].state == uint256(BallotStates.InProgress), "Not InProgress State");
       //require((ballotBasicMap[_ballotId].startTime <= getTime()) && (getTime() <= ballotBasicMap[_ballotId].startTime), "not voting time");

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
    )
    {
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
    )
        internal
    {
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
    function finalizeBallot(uint256 _ballotId, uint256 _ballotState) public onlyGov {
        require(ballotBasicMap[_ballotId].id == _ballotId, "not existed Ballot");
        require(ballotBasicMap[_ballotId].isFinalized == false, "already finalized");
        require((_ballotState == uint256(BallotStates.Accepted)) || (_ballotState == uint256(BallotStates.Rejected)), "Invalid Ballot State");

        BallotBasic storage _ballot = ballotBasicMap[_ballotId];
        _ballot.state = _ballotState;
        _ballot.isFinalized = true;
        emit BallotFinalized (_ballotId,_ballotState);
    }

    function hasAlreadyVoted(uint56 _ballotId, address _voter) public view returns (bool) {
        return hasVotedMap[_ballotId][_voter];
    }

    //start/end /state 
    function startBallot(
        uint256 _ballotId,
        uint256 _startTime,
        uint256 _endTime
    )
        public
        onlyGov
        onlyValidTime(_startTime,_endTime)
    {
        require(ballotBasicMap[_ballotId].id == _ballotId, "not existed Ballot");
        require(ballotBasicMap[_ballotId].isFinalized == false, "already finalized");
        require(ballotBasicMap[_ballotId].state == uint256(BallotStates.Ready), "Not Ready State");
        BallotBasic storage _ballot = ballotBasicMap[_ballotId];
        _ballot.startTime = _startTime;
        _ballot.endTime = _endTime;
        _ballot.state = uint256(BallotStates.InProgress);
        emit BallotStarted(_ballotId, _startTime, _endTime);
    }
    function updateBallotMemo(
        uint256 _ballotId,
        bytes _memo
    ) public onlyGov
    {
        require(ballotBasicMap[_ballotId].id == _ballotId, "not existed Ballot");
        require(ballotBasicMap[_ballotId].isFinalized == false, "already finalized");
        BallotBasic storage _ballot = ballotBasicMap[_ballotId];
        _ballot.memo = _memo;
    }
}

