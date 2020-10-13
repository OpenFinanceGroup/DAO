pragma solidity ^0.5.0; // ^0.6.6;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v2.5.0/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v2.5.0/contracts/token/ERC20/ERC20Detailed.sol";

/*

  ** NOTE : APART FROM LOGIC IMPLEMENTATION, FOLLOWING THINGS NEEDS TO BE IMPLEMENTED : 
    1. CONVERT INTO UPGRADABLE SMART CONTRACT
    2. ERC20 COMPLIANT

*/

contract MultiSignContractUpgradable { // main contract and will contain the reference of MultiSignContractDataStore. MultiSignContractUpgradable will be upgraded.
    
     MultiSignContractDataStore obj;
 
 constructor(address _wldataContract) public {
    obj=MultiSignContractDataStore(_wldataContract) ;
 }
 
  modifier OnlyOwner {
        require(msg.sender == obj.getOwnerAddress());
        _;
    }
    
    function getOwnerAddress() public view returns (address) {
            return obj.getOwnerAddress();
    }
    
    function depositWEI(uint256 value, bytes memory data) public {
        obj.depositWEI(value, data);
    }
    
    function getBalance() public view returns (uint256) { //
        return obj.getBalance();
    }
    
    function requestForWithdrawal(uint value,bytes memory data)
        public 
        returns (string memory)
    {
        return obj.requestForWithdrawal(value, data);   
    }
    
    function confirmTransaction(uint txid) 
        public
        returns(string memory)
    {
        return obj.confirmTransaction(txid); 
    }
    
    function transferAmount(uint txid) 
        public 
        payable
        returns(string memory)
    {
        return obj.transferAmount(txid);
    }
    
    function addTransaction(address destination, uint value, bytes memory data, string memory transType, string memory _creationDate)
        internal
        returns (uint transactionId)
    {
        return obj.addTransaction(destination, value,data, transType,_creationDate);
        
    }
    
    
    function submitTransaction(address destination, uint value,  bytes memory data)
        public
        returns (uint transactionId)
    {
        transactionId = addTransaction(destination, value, data,"transtype","2020/10/10");
      //  confirmTransaction(transactionId);
    }
    
    
    
}

contract MultiSignContractDataStore {  // will contain all the methods and logic
    
     address[] public owners;
     address ownerAddr;
       
      struct Transaction {
            address destination;
            uint value;
            bytes data;
           // string currentState;
           string tranType;
            bool executed;
            uint confirmCount;
            string currentState;
            string creationDate;
    }
    
     constructor() public {
        ownerAddr =msg.sender;
    }
    
	function getOwnerAddress() public view returns (address) {
        return ownerAddr;
    }
    
    
     //Other data structs.
    
    //registered users
    address[] regUsers;
    
    //check for registered users
    mapping(address => bool) isRegUser;
    
    //max num of users
    uint maxNumOfUsers = 32;
    
    //money deposited by each account
    mapping(address => uint) tokensDeposited;
    
    //to check for the owner
    mapping (address => bool) public isOwner;
    
    //its current value be used as a transaction id
    uint public transactionCount=100;
    
    //max no of wei
    uint256 maxWEI = 32000000000000000000;   //equivalent to 32 ethers
    
    //current no,. of wei
    uint256 curWEI = 0;
    
    // transaction related data structs
 
     //all transactionids
    uint[] newtrxids;
    //between txid and Transaction struct
    mapping (uint => Transaction) public transactions;
    
    //between txid and address,to know who has confirmed the transactions.
    mapping(uint => address[]) scores; 
    
    //ERC20 standards.
  // 1. Zeppelin standards.
  // 2. 
  
    
    //function depositWEI(address destination, uint256 value, bytes memory data)  
    function depositWEI(uint256 value, bytes memory data)  
        public
        returns(uint transactionId)
    {
        require(curWEI == maxWEI);
        require(isRegUser[msg.sender]);
        curWEI = curWEI + value;
        tokensDeposited[msg.sender] = value;
    }

    function getBalance() public view returns (uint256) { //
        return address(this).balance;
    }
    
    
    function requestForWithdrawal(uint value,bytes memory data)
        public 
        returns (string memory)
    {
        require(curWEI < maxWEI);
       
        if(curWEI < maxWEI) {
             require(tokensDeposited[msg.sender] <= value);
             msg.sender.transfer(tokensDeposited[msg.sender]);
             return "Tokens transfer done";
        } else  {
            uint txid = addTransaction(msg.sender,value,data,"Withdraw","2020/10/10");
            transactions[txid].currentState ="In process";
            return "Transaction has been placed for approval.Post mininum approval, transfer will be initiated";
        }
    }
    
    
    function confirmTransaction(uint txid) 
        public
        returns(string memory)
    {
        Transaction memory tran = transactions[txid];
        
        // converting from payable to non payable address.
        address addr = address(msg.sender); 
        
        //storing addresses of users whoever has confirmed the transaction.
        scores[txid].push(addr);
        
        //transaction confirmation count
        transactions[txid].confirmCount =  tran.confirmCount + 1;
        
    }
    
    function transferAmount(uint txid) 
        public 
        payable
        returns(string memory)
    {
        
        require(transactions[txid].confirmCount >= 16); //51% of 32
        
        //transfering the amount back to the 
        msg.sender.transfer(address(transactions[txid].destination).balance); 
        
        //converting address to address payable
        address payable payableDestAddr =  address(uint160(transactions[txid].destination)); //payable(transactions[txid].destination); //address(uint160(transactions[txid].destination)); 
        payableDestAddr.transfer(transactions[txid].value);
        curWEI= curWEI - transactions[txid].value;
        return "Tokens transfer done";
        
    }
    
    
    function addTransaction(address destination, uint value, bytes memory data, string memory transType, string memory _creationDate)
        public
        returns (uint transactionId)
    {
        transactionId = transactionCount;
        transactions[transactionId] = Transaction({
            destination: destination,
            value: value,
            data: data,
            tranType: transType,
            executed: false,
            confirmCount: 0,
            currentState: "New",
            creationDate: _creationDate
        });
        transactionCount += 1;
        //Submission(transactionId);
    }
    
    
    function submitTransaction(address destination, uint value,  bytes memory data)
        public
        returns (uint transactionId)
    {
        transactionId = addTransaction(destination, value, data,"transtype","2020/10/10");
      //  confirmTransaction(transactionId);
    }
    
}

/*
contract MultiSignWalletCon {
    
      address[] public owners;
     
       
      struct Transaction {
            address destination;
            uint value;
            bytes data;
           // string currentState;
           string tranType;
            bool executed;
            uint confirmCount;
            string currentState;
            string creationDate;
    }
    
    //Other data structs.
    
    //registered users
    address[] regUsers;
    
    //check for registered users
    mapping(address => bool) isRegUser;
    
    //max num of users
    uint maxNumOfUsers = 32;
    
    //money deposited by each account
    mapping(address => uint) tokensDeposited;
    
    //to check for the owner
    mapping (address => bool) public isOwner;
    
    //its current value be used as a transaction id
    uint public transactionCount=100;
    
    //max no of wei
    uint256 maxWEI = 32000000000000000000;   //equivalent to 32 ethers
    
    //current no,. of wei
    uint256 curWEI = 0;
    
    // transaction related data structs
 
     //all transactionids
    uint[] newtrxids;
    //between txid and Transaction struct
    mapping (uint => Transaction) public transactions;
    
    //between txid and address,to know who has confirmed the transactions.
    mapping(uint => address[]) scores; 
    
  
  //ERC20 standards.
  // 1. Zeppelin standards.
  // 2. 
  
    constructor() public {
        
    }
    
    //function depositWEI(address destination, uint256 value, bytes memory data)  
    function depositWEI(uint256 value, bytes memory data)  
        public
        returns(uint transactionId)
    {
        require(curWEI == maxWEI);
        require(isRegUser[msg.sender]);
        curWEI = curWEI + value;
        tokensDeposited[msg.sender] = value;
    }

    function getBalance() public view returns (uint256) { //
        return address(this).balance;
    }
    
    
    function requestForWithdrawal(uint value,bytes memory data)
        public 
        returns (string memory)
    {
        require(curWEI < maxWEI);
       
        if(curWEI < maxWEI) {
             require(tokensDeposited[msg.sender] <= value);
             msg.sender.transfer(tokensDeposited[msg.sender]);
             return "Tokens transfer done";
        } else  {
            uint txid = addTransaction(msg.sender,value,data,"Withdraw","2020/10/10");
            transactions[txid].currentState ="In process";
            return "Transaction has been placed for approval.Post mininum approval, transfer will be initiated";
        }
    }
    
    
    function confirmTransaction(uint txid) 
        public
        returns(string memory)
    {
        Transaction memory tran = transactions[txid];
        
        // converting from payable to non payable address.
        address addr = address(msg.sender); 
        
        //storing addresses of users whoever has confirmed the transaction.
        scores[txid].push(addr);
        
        //transaction confirmation count
        transactions[txid].confirmCount =  tran.confirmCount + 1;
        
    }
    
    function transferAmount(uint txid) 
        public 
        payable
        returns(string memory)
    {
        
        require(transactions[txid].confirmCount >= 16); //51% of 32
        
        //transfering the amount back to the 
        msg.sender.transfer(address(transactions[txid].destination).balance); 
        
        //converting address to address payable
        address payable payableDestAddr =  address(uint160(transactions[txid].destination)); //payable(transactions[txid].destination); //address(uint160(transactions[txid].destination)); 
        payableDestAddr.transfer(transactions[txid].value);
        curWEI= curWEI - transactions[txid].value;
        return "Tokens transfer done";
        
    }
    
    
    function addTransaction(address destination, uint value, bytes memory data, string memory transType, string memory _creationDate)
        internal
        returns (uint transactionId)
    {
        transactionId = transactionCount;
        transactions[transactionId] = Transaction({
            destination: destination,
            value: value,
            data: data,
            tranType: transType,
            executed: false,
            confirmCount: 0,
            currentState: "New",
            creationDate: _creationDate
        });
        transactionCount += 1;
        //Submission(transactionId);
    }
    
    
    function submitTransaction(address destination, uint value,  bytes memory data)
        public
        returns (uint transactionId)
    {
        transactionId = addTransaction(destination, value, data,"transtype","2020/10/10");
      //  confirmTransaction(transactionId);
    }
    
}
*/