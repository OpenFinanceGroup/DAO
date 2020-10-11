pragma solidity ^0.6.6;

/*

  ** NOTE : APART FROM LOGIC IMPLEMENTATION, FOLLOWING THINGS NEEDS TO BE IMPLEMENTED : 
    1. CONVERT INTO UPGRADABLE SMART CONTRACT
    2. ERC20 COMPLIANT

*/


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
        address payable payableDestAddr = payable(transactions[txid].destination); //address(uint160(transactions[txid].destination)); 
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
    
    //

    

}