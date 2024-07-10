// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {Utils} from "./Utils.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {BananaToken} from "../../contracts/BananaToken.sol";

contract BananaTokenTest is Test {
    BananaToken internal bananaToken;

    Utils internal utils;
    address payable[] internal users;
    address internal alice;
    address internal bob;
    address internal charlie;

    uint256 public bscTestnetFork;
    string public BNB_MAINNET_RPC_URL = vm.envString("BNB_MAINNET_RPC_URL");
    uint256 public constant blockNum = 40285147;
    /**
        16449268
         */
    function setUp() public {
        bscTestnetFork = vm.createSelectFork(BNB_MAINNET_RPC_URL, blockNum);

        utils = new Utils();
        users = utils.createUsers(5);
        alice = users[0];
        bob = users[1];

        bananaToken = new BananaToken(0xcC93A941713e1aA28aDe56a3DB6805F163B10C14);
    }

    function test_BananaToken_Deployment() public view {
        assertEq(
            bananaToken.DEAD(),
            0x000000000000000000000000000000000000dEaD
        );
        assertEq(
            bananaToken.UNISWAP_V2_ROUTER(),
            0x10ED43C718714eb63d5aA57B78B54704E256024E
        );
        assertEq(bananaToken.taxRate(), 5);
        assertEq(
            address(bananaToken.uniswapV2Router()),
            0x10ED43C718714eb63d5aA57B78B54704E256024E
        );
    }

    function test_transfer() public {
        bananaToken.transfer(alice, 1e20);
        assertEq(bananaToken.balanceOf(alice), 1e20);
    }

    function test_transferFrom() public {
        bananaToken.approve(alice, 1e20);
        vm.prank(alice);
        bananaToken.transferFrom(address(this), bob, 1e20);
        assertEq(bananaToken.balanceOf(bob), 1e20);
    }

    function test_taxTransfer() public {
        bananaToken.transfer(alice, 1e20);
        vm.prank(alice);
        bananaToken.transfer(bob, 1e20);
        assertLe(bananaToken.balanceOf(bob), 1e20);
    }

    function test_swap() public {
        bananaToken.transfer(alice, 1e26);
        bananaToken.transfer(bob, 1e26);
        deal(bananaToken.uniswapV2Router().WETH(), alice, 1e26);
        vm.startPrank(alice);
        bananaToken.approve(address(bananaToken.uniswapV2Router()), 1e25);
        IERC20(bananaToken.uniswapV2Router().WETH()).approve(
            address(bananaToken.uniswapV2Router()),
            2e18
        );
        bananaToken.uniswapV2Router().addLiquidity(
            address(bananaToken),
            bananaToken.uniswapV2Router().WETH(),
            1e25,
            2e18,
            0,
            0,
            alice,
            block.timestamp
        );
        vm.stopPrank();
        vm.startPrank(bob);
        bananaToken.approve(address(bananaToken.uniswapV2Router()), 1e24);
        address[] memory path = new address[](2);
        path[0] = address(bananaToken);
        path[1] = bananaToken.uniswapV2Router().WETH();
        bananaToken
            .uniswapV2Router()
            .swapExactTokensForETHSupportingFeeOnTransferTokens(
                1e24,
                0,
                path,
                bob,
                block.timestamp
            );
    }

    function test_addLiquidity() public {
        bananaToken.transfer(alice, 1e26);
        deal(bananaToken.uniswapV2Router().WETH(), alice, 1e26);
        vm.startPrank(alice);
        bananaToken.approve(address(bananaToken.uniswapV2Router()), 1e25);
        IERC20(bananaToken.uniswapV2Router().WETH()).approve(
            address(bananaToken.uniswapV2Router()),
            2e18
        );
        bananaToken.uniswapV2Router().addLiquidity(
            address(bananaToken),
            bananaToken.uniswapV2Router().WETH(),
            1e25,
            2e18,
            0,
            0,
            alice,
            block.timestamp
        );
    }
}
