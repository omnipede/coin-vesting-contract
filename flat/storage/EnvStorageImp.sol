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
        require(Gov(addr).isMember(msg.sender), "No Permission");
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

    mapping(address => uint256) private balance;
    mapping(address => uint256) private lockedBalance;
    uint256 private totalLockedBalance;
    
    event Staked(address indexed payee, uint256 amount, uint256 total, uint256 available);
    event Unstaked(address indexed payee, uint256 amount, uint256 total, uint256 available);
    event Locked(address indexed payee, uint256 amount, uint256 total, uint256 available);
    event Unlocked(address indexed payee, uint256 amount, uint256 total, uint256 available);

    constructor(address registry) public {
        totalLockedBalance = 0;
        setRegistry(registry);
    }

    function balanceOf(address payee) public view returns (uint256) {
        return balance[payee];
    }

    function lockedBalanceOf(address payee) public view returns (uint256) {
        return lockedBalance[payee];
    }

    function availableBalance(address payee) public view returns (uint256) {
        return balance[payee].sub(lockedBalance[payee]);
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
        if (lockedBalance[payee] == 0 || factor == 0) return 0;
        return lockedBalance[payee].mul(factor).div(totalLockedBalance);
    }

    function () external payable {
        revert();
    }

    /**
    * @dev Deposit from a sender.
    */
    function deposit() external nonReentrant payable {
        require(msg.value > 0, "Deposit amount should be greater than zero");

        balance[msg.sender] = balance[msg.sender].add(msg.value);

        emit Staked(msg.sender, msg.value, balance[msg.sender], availableBalance(msg.sender));
    }

    /**
    * @dev Withdraw for a sender.
    * @param amount The amount of funds will be withdrawn and transferred to.
    */
    function withdraw(uint256 amount) external nonReentrant {
        require(amount <= availableBalance(msg.sender), "Withdraw amount should be equal or less than balance");

        balance[msg.sender] = balance[msg.sender].sub(amount);
        msg.sender.transfer(amount);

        emit Unstaked(msg.sender, amount, balance[msg.sender], availableBalance(msg.sender));
    }

    /**
    * @dev Lock fund
    * @param payee The address whose funds will be locked.
    * @param lockAmount The amount of funds will be locked.
    */
    function lock(address payee, uint256 lockAmount) external onlyGov {
        require(balance[payee] >= lockAmount, "Lock amount should be equal or less than balance");
        require(availableBalance(payee) >= lockAmount, "Insufficient balance that can be locked");

        lockedBalance[payee] = lockedBalance[payee].add(lockAmount);
        totalLockedBalance = totalLockedBalance.add(lockAmount);

        emit Locked(payee, lockAmount, balance[payee], availableBalance(payee));
    }

    /**
    * @dev Unlock fund
    * @param payee The address whose funds will be unlocked.
    * @param unlockAmount The amount of funds will be unlocked.
    */
    function unlock(address payee, uint256 unlockAmount) external onlyGov {
        require(lockedBalance[payee] >= unlockAmount, "Unlock amount should be equal or less than balance locked");

        lockedBalance[payee] = lockedBalance[payee].sub(unlockAmount);
        totalLockedBalance = totalLockedBalance.sub(unlockAmount);

        emit Unlocked(payee, unlockAmount, balance[payee], availableBalance(payee));
    }
}

contract EnvConstants {
    bytes32 internal constant BLOCK_PER_NAME = keccak256("blockPer"); 
    uint256 internal constant BLOCK_PER_TYPE = uint256(VariableTypes.Uint);

    bytes32 internal constant BALLOT_DURATION_MIN_NAME = keccak256("ballotDurationMin"); 
    uint256 internal constant BALLOT_DURATION_MIN_TYPE = uint256(VariableTypes.Uint);

    bytes32 internal constant BALLOT_DURATION_MAX_NAME = keccak256("ballotDurationMax"); 
    uint256 internal constant BALLOT_DURATION_MAX_TYPE = uint256(VariableTypes.Uint);

    bytes32 internal constant STAKING_MIN_NAME = keccak256("stakingMin"); 
    uint256 internal constant STAKING_MIN_TYPE = uint256(VariableTypes.Uint);

    bytes32 internal constant STAKING_MAX_NAME = keccak256("stakingMax"); 
    uint256 internal constant STAKING_MAX_TYPE = uint256(VariableTypes.Uint);

    enum VariableTypes {
        Invalid,
        Int,
        Uint,
        Address,
        Bytes32,
        Bytes,
        String
    }
    bytes32 internal constant TEST_INT = keccak256("TEST_INT"); 
    bytes32 internal constant TEST_ADDRESS = keccak256("TEST_ADDRESS"); 
    bytes32 internal constant TEST_BYTES32 = keccak256("TEST_BYTES32"); 
    bytes32 internal constant TEST_BYTES = keccak256("TEST_BYTES"); 
    bytes32 internal constant TEST_STRING = keccak256("TEST_STRING"); 
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
    mapping(uint256 => address) internal members;
    mapping(address => uint256) internal memberIdx;
    uint256 internal memberLength;

    // For enode
    struct Node {
        bytes enode;
        bytes ip;
        uint port;
    }
    mapping(uint256 => Node) internal nodes;
    mapping(address => uint256) internal nodeIdxFromMember;
    mapping(uint256 => address) internal nodeToMember;
    uint256 internal nodeLength;

    // For ballot
    uint256 public ballotLength;
    uint256 public voteLength;
    uint256 internal ballotInVoting;

    constructor() public {
        initialized = false;
        memberLength = 0;
        nodeLength = 0;
        ballotLength = 0;
        voteLength = 0;
        ballotInVoting = 0;
    }

    function isMember(address addr) public view returns (bool) { return (memberIdx[addr] != 0); }
    function getMember(uint256 idx) public view returns (address) { return members[idx]; }
    function getMemberLength() public view returns (uint256) { return memberLength; }
    function getNodeIdxFromMember(address addr) public view returns (uint256) { return nodeIdxFromMember[addr]; }
    function getMemberFromNodeIdx(uint256 idx) public view returns (address) { return nodeToMember[idx]; }
    function getNodeLength() public view returns (uint256) { return nodeLength; }
    function getNode(uint256 idx) public view returns (bytes enode, bytes ip, uint port) {
        return (nodes[idx].enode, nodes[idx].ip, nodes[idx].port);
    }
    function getBallotInVoting() public view returns (uint256) { return ballotInVoting; }

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

contract EternalStorage {
    struct Storage {
        mapping(bytes32 => bool) _bool;
        mapping(bytes32 => int256) _int;
        mapping(bytes32 => uint256) _uint;
        mapping(bytes32 => string) _string;
        mapping(bytes32 => address) _address;
        mapping(bytes32 => bytes) _bytes;
        mapping(bytes32 => bytes32) _bytes32;
    }

    Storage internal s;

    /**
    * @dev Allows the owner to set a value for a boolean variable.
    * @param h The keccak256 hash of the variable name
    * @param v The value to be stored
    */
    function _setBoolean(bytes32 h, bool v) internal {
        s._bool[h] = v;
    }

    /**
    * @dev Allows the owner to set a value for a int variable.
    * @param h The keccak256 hash of the variable name
    * @param v The value to be stored
    */
    function _setInt(bytes32 h, int256 v) internal {
        s._int[h] = v;
    }

    /**
    * @dev Allows the owner to set a value for a boolean variable.
    * @param h The keccak256 hash of the variable name
    * @param v The value to be stored
    */
    function _setUint(bytes32 h, uint256 v) internal {
        s._uint[h] = v;
    }

    /**
    * @dev Allows the owner to set a value for a address variable.
    * @param h The keccak256 hash of the variable name
    * @param v The value to be stored
    */
    function _setAddress(bytes32 h, address v) internal {
        s._address[h] = v;
    }

    /**
    * @dev Allows the owner to set a value for a string variable.
    * @param h The keccak256 hash of the variable name
    * @param v The value to be stored
    */
    function _setString(bytes32 h, string v) internal  {
        s._string[h] = v;
    }

    /**
    * @dev Allows the owner to set a value for a bytes variable.
    * @param h The keccak256 hash of the variable name
    * @param v The value to be stored
    */
    function _setBytes(bytes32 h, bytes v) internal {
        s._bytes[h] = v;
    }
    /**
    * @dev Allows the owner to set a value for a bytes32 variable.
    * @param h The keccak256 hash of the variable name
    * @param v The value to be stored
    */
    function _setBytes32(bytes32 h, bytes32 v) internal {
        s._bytes32[h] = v;
    }
    /**
    * @dev Get the value stored of a boolean variable by the hash name
    * @param h The keccak256 hash of the variable name
    */
    function getBoolean(bytes32 h) public view returns (bool){
        return s._bool[h];
    }

    /**
    * @dev Get the value stored of a int variable by the hash name
    * @param h The keccak256 hash of the variable name
    */
    function getInt(bytes32 h) public view returns (int){
        return s._int[h];
    }

    /**
    * @dev Get the value stored of a uint variable by the hash name
    * @param h The keccak256 hash of the variable name
    */
    function getUint(bytes32 h) public view returns (uint256){
        return s._uint[h];
    }

    /**
    * @dev Get the value stored of a address variable by the hash name
    * @param h The keccak256 hash of the variable name
    */
    function getAddress(bytes32 h) public view returns (address){
        return s._address[h];
    }

    /**
    * @dev Get the value stored of a string variable by the hash name
    * @param h The keccak256 hash of the variable name
    */
    function getString(bytes32 h) public view returns (string){
        return s._string[h];
    }

    /**
    * @dev Get the value stored of a bytes variable by the hash name
    * @param h The keccak256 hash of the variable name
    */
    function getBytes(bytes32 h) public view returns (bytes){
        return s._bytes[h];
    }
    /**
    * @dev Get the value stored of a bytes variable by the hash name
    * @param h The keccak256 hash of the variable name
    */
    function getBytes32(bytes32 h) public view returns (bytes32){
        return s._bytes32[h];
    }
}

contract AEnvStorage is EternalStorage, GovChecker {
    // struct Variable {
    //     bytes32 _name;
    //     uint256 _type;
    //     string _value;
    // }
   
    event StringVarableChanged ( 
        bytes32 indexed _name,
        string _value
    );
    event UintVarableChanged ( 
        bytes32 indexed _name,
        uint _value
    );
    event IntVarableChanged ( 
        bytes32 indexed _name,
        int _value
    );
    event AddressVarableChanged ( 
        bytes32 indexed _name,
        address _value
    );
    event Bytes32VarableChanged ( 
        bytes32 indexed _name,
        bytes32 _value
    );
    event BytesVarableChanged ( 
        bytes32 indexed _name,
        bytes _value
    );

    event VarableChanged ( 
        bytes32 indexed _name,
        uint256 indexed _type,
        string _value
    );
   
    /**
    * @dev Allows the owner to set a value for a int variable.
    * @param h The keccak256 hash of the variable name
    * @param v The value to be stored
    */
    function setInt(bytes32 h, int256 v) internal {
        _setInt(h, v);
        emit IntVarableChanged(h,v);
    }

    /**
    * @dev Allows the owner to set a value for a boolean variable.
    * @param h The keccak256 hash of the variable name
    * @param v The value to be stored
    */
    function setUint(bytes32 h, uint256 v) internal {
        _setUint(h, v);
        emit UintVarableChanged(h,v);
    }

    /**
    * @dev Allows the owner to set a value for a address variable.
    * @param h The keccak256 hash of the variable name
    * @param v The value to be stored
    */
    function setAddress(bytes32 h, address v) internal {
        _setAddress(h, v);
        emit AddressVarableChanged(h,v);
    }

    /**
    * @dev Allows the owner to set a value for a string variable.
    * @param h The keccak256 hash of the variable name
    * @param v The value to be stored
    */
    function setString(bytes32 h, string v) internal  {
        _setString(h, v);
        emit StringVarableChanged(h,v);
    }

    /**
    * @dev Allows the owner to set a value for a bytes variable.
    * @param h The keccak256 hash of the variable name
    * @param v The value to be stored
    */
    function setBytes(bytes32 h, bytes v) internal {
        _setBytes(h, v);
        emit BytesVarableChanged(h,v);
    }
    /**
    * @dev Allows the owner to set a value for a bytes32 variable.
    * @param h The keccak256 hash of the variable name
    * @param v The value to be stored
    */
    function setBytes32(bytes32 h, bytes32 v) internal {
        _setBytes32(h, v);
        emit Bytes32VarableChanged(h,v);
    }



    // mapping(bytes32 => Variable) internal s;

    // /**
    // * @dev Add a new variable .
    // * @param _h The keccak256 hash of the variable name
    // * @param _t The type of value
    // * @param _v The value to be stored
    // */
    // function _add(bytes32 _h, uint256 _t, string _v) internal  {
    //     require(s[_h]._name == "","not found");
    //     s[_h] = Variable(_h,_t,_v);
    //     emit VarableAdded(_h,_t,_v);
    // }
    // /**
    // * @dev Update a new variable .
    // * @param _h The keccak256 hash of the variable name
    // * @param _t The type of value
    // * @param _v The value to be stored
    // */
    // function _change(bytes32 _h, uint256 _t, string _v) internal {
    //     require(s[_h]._name == _h,"not found");
    //     Variable storage v = s[_h];
    //     v._name = _h;
    //     v._type = _t;
    //     v._value = _v;
    //     emit VarableChanged(_h,_t,_v);

    // }
    // /**
    // * @dev Get the type & value stored of a string variable by the hash name
    // * @param _h The keccak256 hash of the variable name
    // */
    // function get(bytes32 _h) public view returns (uint256 varType, string varVal){
    //     //require(s[_h]._name == _h,"not found");
    //     return (s[_h]._type, s[_h]._value);
    // }
    // /**
    // * @dev Get the type stored of a string variable by the hash name
    // * @param _h The keccak256 hash of the variable name
    // */
    // function getType(bytes32 _h) public view returns (uint256){
    //     require(s[_h]._name == _h,"not found");
    //     return s[_h]._type;
    // }
    // /**
    // * @dev Get the value stored of a string variable by the hash name
    // * @param _h The keccak256 hash of the variable name
    // */
    // function getValue(bytes32 _h) public view returns (string){
    //     require(s[_h]._name == _h,"not found");
    //     return s[_h]._value;
    // }
    
}

contract EnvStorageImp is AEnvStorage, EnvConstants {
    using SafeMath for uint256;
    //using Conversion for string;
    
    function initialize() public onlyOwner{
        uint256 blockPerVal = getBlockPerValue();
        uint256 ballotDurationMin = getBallotDurationMinValue();
        uint256 ballotDurationMax = getBallotDurationMaxValue();
        uint256 stakingMin = getStakingMinValue();
        uint256 stakingMax = getStakingMaxValue();
        if( blockPerVal == 0){
            setUint(BLOCK_PER_NAME, 1000);
        }
        if( ballotDurationMin == 0){
            setUint(BALLOT_DURATION_MIN_NAME, 604800);
        }
        if( ballotDurationMax == 0 ){
            setUint(BALLOT_DURATION_MAX_NAME, 604800);
        }
        if( stakingMin == 0 ){
            setUint(STAKING_MIN_NAME, 10000000000);
        }
        if( stakingMax == 0 ){
            setUint(STAKING_MAX_NAME, 20000000000);
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
    event testCodeValue(bytes _bytes,string _string);
    function setTestStringByBytes(bytes _value) public onlyGov { 
        emit testCodeValue(_value,string(_value));
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
    
    function toBytes32( bytes memory  _input) internal pure  returns (bytes32 _output){
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
    function toString( bytes memory _input ) public pure returns(string memory _output) {
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

    function bytes32ToBytes( bytes32 _input) internal pure returns(bytes) {
        bytes memory _output = new bytes(32);
        assembly {
            mstore(add(_output, 32), _input)
            mstore(add(add(_output,32),32), add(_input,32))
        }
        return _output;
    }
    function intToBytes(int _input) public pure returns(bytes memory _output) {
        _output = new bytes(32);
        assembly {
            mstore(add(_output, 32), _input)
        }
    } 
    
    function uintToBytes(uint _input) public pure returns(bytes memory _output) {
        _output = new bytes(32);
        assembly {
            mstore(add(_output, 32), _input)
        }
    }
    
    function addressToBytes(address _input) public pure returns (bytes _output){
        assembly {
            let m := mload(0x40)
            mstore(add(m, 20), xor(0x140000000000000000000000000000000000000000, _input))
            mstore(0x40, add(m, 52))
            _output := m
        }
    }
    
    function stringToBytes(string memory _input) public pure returns(bytes _output){
        //_output = bytes(_input);
        _output =  abi.encode(_input);
    }
    





}

