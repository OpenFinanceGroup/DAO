pragma solidity ^0.5.0; // ^0.6.6;


pragma solidity ^0.5.0; // ^0.6.6;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v2.5.0/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v2.5.0/contracts/token/ERC20/ERC20Detailed.sol";

/*

  ** NOTE : APART FROM LOGIC IMPLEMENTATION, FOLLOWING THINGS NEEDS TO BE IMPLEMENTED : 
    1. CONVERT INTO UPGRADABLE SMART CONTRACT
    2. ERC20 COMPLIANT
    
    0x3643b7a9F6338115159a4D3a2cc678C99aD657aa   data
    

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
    
    function depositWEI() payable public returns(uint) {
        obj.depositWEI(msg.sender);
    }

    function requestForWithdrawal(uint value,string memory data)
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
      //  returns(string memory)
        returns(address)
    {
        return obj.transferAmount(msg.sender, txid);
    }
    
    function submitTransaction(address destination, uint value,  string memory data)
        public
        returns (uint transactionId)
    {
       // submitTransaction(address destination, uint value, string memory data)
        transactionId = obj.submitTransaction(msg.sender, value, data);
      //  confirmTransaction(transactionId);
    }
    
    function getContractBalance() public view returns (uint256) { 
        return address(this).balance;
    }
    
    
    /*
    
    
     function addTransaction(uint value, string memory data, string memory transType, string memory _creationDate) //not required
        internal
        returns (uint transactionId)
    {
        return obj.addTransaction(msg.sender, value,data, transType,_creationDate);
        
    }
    
      function getContractBalanceData() public view returns(uint256) { //test
       return obj.getContractBalance();
    }
    

    function getContractAddressData() public view returns(address) { //test
       return obj.getCallingAddr();
    }
    
    function getCallingAddrDataBal() public view returns(uint) { //test
       return obj.getBalance();
    }
    
    function getCallingAddr() public view returns(address) { //test
       return msg.sender;
    }
    
    function getContractBalance() public view returns (uint256) { 
        return address(this).balance;
    }
    
     function getContractBalanceData() public view returns(uint256) { //test
       return obj.getContractBalance();
    }
    
    
    0xb3502940731B7a65F9bbDB73369c7729c8197665
    0xb3502940731B7a65F9bbDB73369c7729c8197665
    
    -- 
    0xc5266CA19406253Bd9659c5689cC6dfcFd4633A8 data
    0x0B2f1fc73fd95d53Ef57af3Ca4155EC97725350d
    
    0xc77e7328722F996Acd268b5Ac786e94120339A7F  data
    0x300320319533473E6df7fbbBac1B81ed864Ccf58
    
    */
    

    
    
    function getContractAddress() public view returns(address) { //test
       return msg.sender;
    }
    
    function getAddressBalance(address _addr) public view returns(uint) { //test
       return obj.getAddressBalance(_addr);
    }
    
     function getTxBalance(uint _txid) public view returns(uint) { //test
       return obj.getTxBalance(_txid);
    }
    
    
}


contract MultiSignContractDataStore {  // will contain all the methods and logic
    
     address[] public owners;
     address ownerAddr;
       
      struct Transaction {
            address destination;
            uint value;
            string data;
            // bytes data;
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
    uint256 maxWEI = 32000000000000000000 wei;   //equivalent to 32 ethers
    
    //current no,. of wei
    uint256 curWEI = 16000000000000000000 wei; // for testing purpose
    
    // transaction related data structs
 
     //all transactionids
    uint[] newtrxids;
    //between txid and Transaction struct
    mapping (uint => Transaction) public transactions;
    
    //between txid and address,to know who has confirmed the transactions.
    mapping(uint => address[]) scores; 
    
    //between txid and balance.
    mapping(uint => uint) txidBalance; 
    
    //ERC20 standards.
  // 1. Zeppelin standards.
  // 2. 
  
  
    constructor() public {
        ownerAddr =msg.sender;
    }
    
	function getOwnerAddress() public view returns (address) {
        return ownerAddr;
    }
    
    function getContractBalance() public view returns(uint256) { //test
       return address(this).balance; //address(this).balance;
    }
    
    function getContractAddress() public view returns(address) { //test
       return address(this);
    }

    function depositWEI(address _addr)  
        payable public
        returns(uint)
    {
        require(curWEI < maxWEI); 
       // require(isRegUser[msg.sender]); //commented for the testing purpose
        curWEI = curWEI + msg.value;//value;
        tokensDeposited[_addr] = msg.value;
        return _addr.balance;
    }
    

    function getCallingAddr() public view returns(address) { //test
       return msg.sender;
    }

    function getBalance() public view returns (uint) { //
        return address(this).balance;
    }

    function requestForWithdrawal(uint value,string memory data)
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
    
    //0x5B38Da6a701c568545dCfcB03FcB875f56beddC4   99999999999993641749
    //
    
    function transferAmount(address _addr, uint txid) //to be tested next.
        public 
      //  payable
        returns(address)
    {
        
       // require(transactions[txid].confirmCount >= 16); //51% of 32  commented for testing purpose
        
        //deducting the amount from the contract balance
       // msg.sender.transfer(transactions[txid].value); //from contract to address
        
        //converting address to address payable
       // address payable payableDestAddr =  address(uint160(transactions[txid].destination)); //payable(transactions[txid].destination); //address(uint160(transactions[txid].destination)); 
        
        //payableDestAddr.transfer(transactions[txid].value);
       // curWEI= curWEI - transactions[txid].value;
       // return "Tokens transfer done";
       
      address(uint160(_addr)).transfer(transactions[txid].value);
       return _addr;
        
    }
    
    
    function addTransaction(address destination, uint value, string memory data, string memory transType, string memory _creationDate)
        public
        returns (uint transactionId)
    {
        transactionId = transactionCount;
        transactions[transactionId] = Transaction({
            destination: destination, //address which deposited the ethers/wei
            value: value,
            data: data,
            tranType: transType,
            executed: false,
            confirmCount: 0,
            currentState: "New",
            creationDate: _creationDate
        });
        uint curTnxid = transactionCount;
        transactionCount += 1;
        return curTnxid;
        //Submission(transactionId);
    }
    
  
    function submitTransaction(address destination, uint value, string memory data)
        public
        returns (uint transactionId)
    {
        transactionId = addTransaction(destination, value, data,"transtype","2020/10/10");
        return transactionId;
      //  confirmTransaction(transactionId);
    }
    
    function getAddressBalance(address _addr) public view returns(uint) { //test
       return _addr.balance;
    }
    
    function getTxBalance(uint _txid) public view returns(uint256) { //test
          return  transactions[_txid].value;
      // return obj.getAddressBalance(_addr);
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
    function depositWEI(uint value)  
        payable public
        returns(uint)
    {
       // require(curWEI == maxWEI);
      //  require(isRegUser[msg.sender]);
        curWEI = curWEI + value;
        tokensDeposited[msg.sender] = value;
        return address(this).balance;
    }
    
     function depositToContract(uint value) public payable returns (uint) {
        //balances[msg.sender] += msg.value;
        //emit LogDepositMade(msg.sender, msg.value);
        //return balances[msg.sender];
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
    
     function getCallingAddr() public view returns(address) { //test
       return msg.sender;
    }


    function getBalance() public view returns (uint) { // test
        return address(this).balance;
    }
    

}

*/