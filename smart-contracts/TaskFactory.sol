// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;

import "./Task.sol";

contract TaskFactory{
    //Matic contract address on Mumbai testnet
    IERC20 public TOKEN = IERC20(address(0xbe188D6641E8b680743A4815dFA0f6208038960F));
    
    //manager is Aster address on Metamask
    address payable manager = payable(0xfa90cf3EEC661772dD952cB9125a6f64B9B07e28);
    address[] public tasks;
    uint id;
    
        
    //announcements
    event newTaskCreation(uint id, address taskAdd);
    
    constructor() {
    }
    
    //backend calls to create a Task SC
    function create(uint numLabelers, uint256 amount) public payable returns(address, uint){
        amount = amount * 10**18;
        address taskOwner = msg.sender;
        id = tasks.length;
        
        require(TOKEN.balanceOf(msg.sender) >= amount, "TaskFactory: insufficient funds.");
        require(msg.value == amount, "TaskFactory: Unmatching funds.");
        
        //5% of payment amount is collected as process fees
        uint256 fees = (5 * amount)/100;
        TOKEN.transfer(manager, fees);
        //update remaining amount to pay to the task
        amount = amount - fees;

        //create new task and add to the array
        Task newtask = new Task(id, taskOwner, numLabelers, amount);
        TOKEN.transfer(address(newtask), amount);
        
        tasks.push(address(newtask));

        
        emit newTaskCreation(id, address(newtask));

        return (address(newtask), id);
    }
    

//------------HELPER FUNCTIONS------------------------

    function getAddress(uint _id) public view returns(address){
        // require(manager == msg.sender, "TaskFactory: permission denied.");
        return tasks[_id];
    }

    function getNumDeployedTasks() public view returns(uint){
        // require(manager == msg.sender, "TaskFactory: permission denied.");
        return tasks.length;
    }
    
    
}