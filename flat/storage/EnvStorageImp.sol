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

contract AEnvStorage is GovChecker {
    struct Variable {
        bytes32 _name;
        uint256 _type;
        string _value;
    }
   
    event VarableAdded ( 
        bytes32 indexed _name,
        uint256 indexed _type,
        string _value
    );
    event VarableChanged ( 
        bytes32 indexed _name,
        uint256 indexed _type,
        string _value
    );
   
    mapping(bytes32 => Variable) internal s;
 
    /**
    * @dev Add a new variable .
    * @param _h The keccak256 hash of the variable name
    * @param _t The type of value
    * @param _v The value to be stored
    */
    function _add(bytes32 _h, uint256 _t, string _v) internal  {
        require(s[_h]._name == "","not found");
        s[_h] = Variable(_h,_t,_v);
        emit VarableAdded(_h,_t,_v);
    }
    /**
    * @dev Update a new variable .
    * @param _h The keccak256 hash of the variable name
    * @param _t The type of value
    * @param _v The value to be stored
    */
    function _change(bytes32 _h, uint256 _t, string _v) internal {
        require(s[_h]._name == _h,"not found");
        Variable storage v = s[_h];
        v._name = _h;
        v._type = _t;
        v._value = _v;
        emit VarableChanged(_h,_t,_v);

    }
    /**
    * @dev Get the type & value stored of a string variable by the hash name
    * @param _h The keccak256 hash of the variable name
    */
    function get(bytes32 _h) public view returns (uint256 varType, string varVal){
        require(s[_h]._name == _h,"not found");
        return (s[_h]._type, s[_h]._value);
    }
    /**
    * @dev Get the type stored of a string variable by the hash name
    * @param _h The keccak256 hash of the variable name
    */
    function getType(bytes32 _h) public view returns (uint256){
        require(s[_h]._name == _h,"not found");
        return s[_h]._type;
    }
    /**
    * @dev Get the value stored of a string variable by the hash name
    * @param _h The keccak256 hash of the variable name
    */
    function getValue(bytes32 _h) public view returns (string){
        require(s[_h]._name == _h,"not found");
        return s[_h]._value;
    }
}

contract EnvStorageImp is AEnvStorage, EnumVariableTypes {
    bytes32 internal constant BLOCK_PER_NAME = keccak256("blockPer"); 
    uint256 internal constant BLOCK_PER_TYPE = uint256(VariableTypes.Uint);

    function getBlockPer() public view returns (uint256 varType, string varVal) {
        varType = getBlockPerType();
        varVal = getBlockPerValue();
    }
    function getBlockPerType() public view returns (uint256) {
        return getType(BLOCK_PER_NAME);
    }
    function getBlockPerValue() public view returns (string) {
        return getValue(BLOCK_PER_NAME);
    }
    function setBlockPer(string _value) public onlyGov { 
        _set(BLOCK_PER_NAME, BLOCK_PER_TYPE, _value);
    }
    /**
    * @dev set a value for a string variable.
    * @param _h The keccak256 hash of the variable name
    * @param _t The type of value
    * @param _v The value to be stored
    */
    function _set(bytes32 _h, uint256 _t,string _v) internal {
        require(_t >= uint256(VariableTypes.Int), "Invalid Variable Type");
        require(_t <= uint256(VariableTypes.String), "Invalid Variable Type");
        require(bytes(_v).length > 0, "empty value");
        if(s[_h]._name == "") {
            _add(_h, _t, _v);
        }else{
            _change(_h, _t, _v);
        }
    }
}

