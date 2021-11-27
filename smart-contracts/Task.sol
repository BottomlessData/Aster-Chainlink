// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;

import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract Task{  
    // // This function is called for plain Ether transfers, i.e.
    // // for every call with empty calldata.
    receive() external payable { }
    fallback() external payable {}  

    //Interfacing chainlink pricefeed oracle
    //Aggreator: MATIC/USD on Mumbai Testnet
    //Address: 0xd0D5e3DB44DE05E9F294BB0a3bEEaF030DE24Ada
    AggregatorV3Interface internal priceFeed = AggregatorV3Interface(address(0xd0D5e3DB44DE05E9F294BB0a3bEEaF030DE24Ada));

    
    //declare required variables
    address public taskOwner;
    //manager is Aster address on Metamask
    address payable manager = payable(0xfa90cf3EEC661772dD952cB9125a6f64B9B07e28);
    
    uint numLabelers;
    uint numLabelersPaid;
    uint TaskId;
    bool TaskOpen;
    uint256 totalAmount;
    uint256 rewardPerLabeler;
    uint256 fees;

    constructor(uint TID, address tOwner, uint nLabelers, uint256 amount) payable{     
        // initialize variables
        taskOwner = tOwner;
        TaskId = TID;
        TaskOpen = true;
        numLabelers = nLabelers;
        totalAmount = amount;
        rewardPerLabeler = totalAmount / numLabelers;
        numLabelersPaid = 0;
    }
    
    
    //frontend calls to add funds to task
    function fundTask(uint256 amount) public payable{
        amount = amount * 10**18;
        // require(msg.sender == taskOwner, "Task: Only Task Owner can fund this contract.");
        // require(TOKEN.balanceOf(msg.sender) >= amount, "Task: insufficient funds.");
        require(msg.sender.balance >= amount, "Task: insufficient funds.");
        require(msg.value == amount, "Task: Unmatching funds.");
        
        feeCalculations(amount);
    }
    
    function feeCalculations(uint256 amount) private {
        //5% of payment amount is collected as process fees
        fees = (5 * amount)/100;
        manager.transfer(fees);
        
        //update totalAmount after paying fees
        totalAmount = totalAmount + (amount - fees);
        
        //reward per each labeler
        rewardPerLabeler = totalAmount / numLabelers;
    }

    //frontend calls
    function submission(address payable labeler) public{
        require(TaskOpen == true, "Task: Task is closed.");
        //payLabeler once task owner approves submission
        payLabeler(labeler);
        
        //track number of labelers paid and closed task if all have been paid
        numLabelersPaid = numLabelersPaid + 1;
        if (numLabelersPaid == numLabelers){
            TaskOpen = false;
        }
    }
    
    function payLabeler(address payable labeler) private{
        //transfer MATIC to labeler
        labeler.transfer(rewardPerLabeler);
        //update totalAmount
        totalAmount = totalAmount - rewardPerLabeler;
    }


    // string comparison :keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b))
    // function setToken(string memory _token) internal{
    //     if (keccak256(abi.encodePacked(_token)) == keccak256(abi.encodePacked("matic"))){
    //         //MATIC contract address on Mumbai testnet
    //         TOKEN = IERC20(address(0xbe188D6641E8b680743A4815dFA0f6208038960F));
    //         //Aggreator: MATIC/USD on Mumbai Testnet
    //         //Address: 0xd0D5e3DB44DE05E9F294BB0a3bEEaF030DE24Ada
    //         priceFeed = AggregatorV3Interface(0xd0D5e3DB44DE05E9F294BB0a3bEEaF030DE24Ada);
    //     }
        // if (keccak256(abi.encodePacked(_token)) == keccak256(abi.encodePacked("usdt"))){
        //      //USDT contract address on Mumbai testnet
        //     TOKEN = IERC20(address(0xe07D7B44D340216723eD5eA33c724908B817EE9D));
        //     //Aggreator: USDT/USD on Mumbai Testnet
        //     //Address: 0x92C09849638959196E976289418e5973CC96d645
        //     priceFeed = AggregatorV3Interface(0x92C09849638959196E976289418e5973CC96d645);

        // }
    // }
    
//------------HELPER FUNCTIONS------------------------
    
    //get balance of Task SC
    function getTaskBalance() public view returns(uint){
        return address(this).balance;
    }
    
    function getTaskID() public view returns(uint){
        return TaskId;
    }
    
    //get reward per labeler
    function getRewardPerLabeler() public view returns(uint){
        return rewardPerLabeler;
    }
    
    function getNumLabelers() public view returns(uint){
        return numLabelers;
    }
        
    function getTotalAmount() public view returns(uint256){
        return totalAmount;
    }
        
    //get state of the Task 
    function getTaskState() public view returns(bool){
        return TaskOpen;
    }
    
    //get fees charged for this task
    function getFees() public view returns(uint256){
        return fees;
    }
    
    //get balance of the sender 
    function getBalance() public view returns(uint256){
        return msg.sender.balance;
    }
        
    //get number of labelers paid
    function getnumLabelersPaid() public view returns(uint){
        return numLabelersPaid;
    }
    
    /**
     * Returns the latest price of TOKEN in USD
     */
    function getLatestPrice() public view returns (int) {
        (
            uint80 roundID, 
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        ) = priceFeed.latestRoundData();
        return price;
    }

}

