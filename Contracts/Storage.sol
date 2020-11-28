
pragma solidity ^0.5.0;

contract Storage {
    
    address owner;
     
   struct Transaction {
            address destination;
            uint value;
            string tranType;
            bool executed;
            uint confirmCount;
            uint rejectCount;
            string currentState;
            uint256 creationDate;
            uint256 transferDate;
      }
    
    //Other data structs.
    
    //registered users
    address[] regUsers;
    
    //check for registered users
    mapping(address => bool) isRegUser;
    
    //curent count of registered users
    uint numOfUsers = 0;
    
    //money deposited by each account
    mapping(address => uint) tokensDeposited;
    
    //to check for the owner
    //mapping (address => bool) public isOwner;
    
    //its current value be used as a transaction id
    uint public transactionCount=100;
    
    //max no of wei
    uint256 maxWEI = 32000000000000000000;   //equivalent to 32 ethers
    
    //current no,. of wei
    uint256 curWEI = 0;
    
    // transaction related data structs
 
     //all transactionids (corresponds to the withdrawal request)
    uint[] newtrxids;
    
    //between txid and Transaction struct
    mapping (uint => Transaction) public transactions;
    
    //between txid and address,to know who has confirmed the transactions.
    mapping(uint => address[]) scores; 
    
    //storing addresses of users whoever has confirmed the transaction.
    mapping(uint => address[]) confirmedTxToAddrMapping;
    
    //storing addresses of users whoever has confirmed the transaction.
    mapping(uint => address[]) rejectedTxToAddrMapping;
    
    //mapping between user and the most recent withdrawal request.
    mapping(address => Transaction) recentWithdrawRequest;
    
    mapping(address => mapping(uint => bool)) hasConfirmed;
    
    
    struct Reward {
            address useraddr;
            uint valueStacked;
            uint reward;
            uint256 _time;
      }
      
     mapping (address => Reward[]) userRewardMapping;
    

    
    // for ERC20
    string public constant name = "OpenFinToken";
    string public constant symbol = "OFT";
    uint8 public constant decimals = 18; 
    uint256 totalSupply_;

    //hold the token balance of each owner account.
    mapping(address => uint256) balances;
    
    // mapping object, allowed, will include all of the accounts approved to withdraw from a given account together with the withdrawal sum allowed for each.
    mapping(address => mapping (address => uint256)) allowed;
 
}
