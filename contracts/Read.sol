// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

import {IUniswapV2Pair} from "./interfaces/IUniswapV2Pair.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Read {
    address public immutable bananaToken;
    IUniswapV2Pair public immutable uniswapV2Pair;

    constructor(address _bananaToken, address _uniswapV2Pair) {
        bananaToken = _bananaToken;
        uniswapV2Pair = IUniswapV2Pair(_uniswapV2Pair);
    }

    function getBananaTokenPriceInETH() external view returns (uint256) {
        (uint112 reserve0, uint112 reserve1, ) = uniswapV2Pair.getReserves();

        address token0 = uniswapV2Pair.token0();
        address token1 = uniswapV2Pair.token1();

        uint256 bananaReserve;
        uint256 wethReserve;

        if (token0 == bananaToken) {
            bananaReserve = uint256(reserve0);
            wethReserve = uint256(reserve1);
        } else if (token1 == bananaToken) {
            bananaReserve = uint256(reserve1);
            wethReserve = uint256(reserve0);
        } else {
            revert("Invalid pair");
        }
        require(bananaReserve > 0, "Invalid Reserve");
        // price of 1 BananaToken in WETH
        uint256 bananaTokenPriceInETH = (wethReserve * 1e18) / bananaReserve;
        return bananaTokenPriceInETH;
    }
}
