// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {Utils} from "./Utils.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IUniswapV2Router02} from "../../contracts/interfaces/IUniswapV2Router02.sol";
import {IUniswapV2Factory} from "../../contracts/interfaces/IUniswapV2Factory.sol";
import {BANA} from "../../contracts/BANA.sol";

contract banaTest is Test {
    BANA internal bana;
    address private constant UNISWAP_V2_ROUTER =
        0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address private constant WETH = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    Utils internal utils;
    address payable[] internal users;
    address internal alice;
    address internal bob;
    address internal charlie;

    uint256 public bscTestnetFork;
    string public BNB_MAINNET_RPC_URL = vm.envString("BNB_MAINNET_RPC_URL");
    uint256 public constant blockNum = 40406990;
    /**
        16449268
         */
    function setUp() public {
        bscTestnetFork = vm.createSelectFork(BNB_MAINNET_RPC_URL, blockNum);

        utils = new Utils();
        users = utils.createUsers(5);
        alice = users[0];
        bob = users[1];

        bana = new BANA();
    }

    function test_BANA_Deployment() public view {
        // assertEq(
        //     bana.DEAD(),
        //     0x000000000000000000000000000000000000dEaD
        // );
        // assertEq(
        //     bana.UNISWAP_V2_ROUTER(),
        //     0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        // );
        // assertEq(bana.taxRate(), 5);
        // assertEq(
        //     address(bana.uniswapV2Router()),
        //     0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        // );
    }

    function test_transfer() public {
        bana.transfer(alice, 1e20);
        assertEq(bana.balanceOf(alice), 1e20);
    }

    function test_openTradingTransfer() public {
        payable(address(bana)).transfer(2 ether);
        bana.transfer(address(bana), 21e25 * 70 / 100);
        bana.openTrading();
        bana.transfer(alice, 1e20);
        assertEq(bana.balanceOf(alice), 1e20);
    }

    function test_transferFrom() public {
        bana.approve(alice, 1e20);
        vm.prank(alice);
        bana.transferFrom(address(this), bob, 1e20);
        assertEq(bana.balanceOf(bob), 1e20);
    }

    function test_openTradingTransferFrom() public {
        payable(address(bana)).transfer(2 ether);
        bana.transfer(address(bana), 21e25 * 70 / 100);
        bana.openTrading();
        bana.approve(alice, 1e20);
        vm.prank(alice);
        bana.transferFrom(address(this), bob, 1e20);
        assertEq(bana.balanceOf(bob), 1e20);
    }

    function test_noTaxTransfer() public {
        bana.transfer(alice, 1e20);
        assertLe(bana.balanceOf(alice), 1e20);
        vm.prank(alice);
        bana.transfer(bob, 1e20);
        assertEq(bana.balanceOf(bob), 1e20);
    }

    function test_openTradingNoTaxTransfer() public {
        payable(address(bana)).transfer(2 ether);
        bana.transfer(address(bana), 21e25 * 70 / 100);
        bana.openTrading();
        bana.transfer(alice, 1e20);
        vm.prank(alice);
        bana.transfer(bob, 1e20);
        assertEq(bana.balanceOf(bob), 1e20);
    }

    function test_swap() public {
        deal(WETH, address(this), 1e26);
        bana.approve(UNISWAP_V2_ROUTER, 1e25);
        IERC20(WETH).approve(address(UNISWAP_V2_ROUTER), 2e18);
        IUniswapV2Router02(UNISWAP_V2_ROUTER).addLiquidity(
            address(bana),
            WETH,
            1e25,
            2e18,
            0,
            0,
            address(this),
            block.timestamp
        );
        console.log("marketingWallet balance before swap");
        console.log(bana.balanceOf(0xcC93A941713e1aA28aDe56a3DB6805F163B10C14));
        console.log(
            IERC20(WETH).balanceOf(0xcC93A941713e1aA28aDe56a3DB6805F163B10C14)
        );
        console.log(
            address(0xcC93A941713e1aA28aDe56a3DB6805F163B10C14).balance
        );

        bana.transfer(alice, 1e26);
        bana.transfer(bob, 1e26);
        deal(WETH, alice, 1e26);
        vm.startPrank(alice);
        bana.approve(UNISWAP_V2_ROUTER, 1e25);
        IERC20(WETH).approve(UNISWAP_V2_ROUTER, 2e18);
        IUniswapV2Router02(UNISWAP_V2_ROUTER).addLiquidity(
            address(bana),
            WETH,
            1e25,
            2e18,
            0,
            0,
            alice,
            block.timestamp
        );
        vm.stopPrank();
        vm.startPrank(bob);
        bana.approve(UNISWAP_V2_ROUTER, 1e24);
        address[] memory path = new address[](2);
        path[0] = address(bana);
        path[1] = WETH;
        IUniswapV2Router02(UNISWAP_V2_ROUTER)
            .swapExactTokensForETHSupportingFeeOnTransferTokens(
                1e24,
                0,
                path,
                bob,
                block.timestamp
            );
        vm.stopPrank();
        console.log("marketingWallet balance after swap");
        console.log(bana.balanceOf(0xcC93A941713e1aA28aDe56a3DB6805F163B10C14));
        console.log(
            IERC20(WETH).balanceOf(0xcC93A941713e1aA28aDe56a3DB6805F163B10C14)
        );
        console.log(
            address(0xcC93A941713e1aA28aDe56a3DB6805F163B10C14).balance
        );
    }

    function test_addLiquidity() public {
        deal(WETH, address(this), 1e26);
        bana.approve(UNISWAP_V2_ROUTER, 1e25);
        IERC20(WETH).approve(UNISWAP_V2_ROUTER, 2e18);
        IUniswapV2Router02(UNISWAP_V2_ROUTER).addLiquidity(
            address(bana),
            WETH,
            1e25,
            2e18,
            0,
            0,
            alice,
            block.timestamp
        );

        bana.transfer(alice, 1e26);
        deal(WETH, alice, 1e26);
        vm.startPrank(alice);
        bana.approve(UNISWAP_V2_ROUTER, 1e25);
        IERC20(WETH).approve(UNISWAP_V2_ROUTER, 2e18);
        IUniswapV2Router02(UNISWAP_V2_ROUTER).addLiquidity(
            address(bana),
            WETH,
            1e25,
            2e18,
            0,
            0,
            alice,
            block.timestamp
        );
        vm.stopPrank();
    }

    function test_goThrough() public {
        payable(address(bana)).transfer(2 ether);
        bana.transfer(address(bana), (21e25 * 70) / 100);
        bana.openTrading();
        assertEq(bana.balanceOf(address(bana)), 0);
        bana.transfer(bob, 1e24);
        vm.startPrank(bob);
        bana.approve(UNISWAP_V2_ROUTER, 1e24);
        address[] memory path = new address[](2);
        path[0] = address(bana);
        path[1] = WETH;
        IUniswapV2Router02(UNISWAP_V2_ROUTER)
            .swapExactTokensForETHSupportingFeeOnTransferTokens(
                1e24,
                0,
                path,
                bob,
                block.timestamp
            );
        vm.stopPrank();
        address pair = IUniswapV2Factory(
            IUniswapV2Router02(UNISWAP_V2_ROUTER).factory()
        ).getPair(address(bana), WETH);
        uint256 liquidity = IERC20(pair).balanceOf(address(this));

        IERC20(pair).approve(UNISWAP_V2_ROUTER, liquidity);
        IUniswapV2Router02(UNISWAP_V2_ROUTER).removeLiquidity(
            address(bana),
            WETH,
            liquidity / 10,
            0,
            0,
            address(this),
            block.timestamp
        );
    }

    function test_removeLiquidity() public {
        test_swap();
        address pair = IUniswapV2Factory(
            IUniswapV2Router02(UNISWAP_V2_ROUTER).factory()
        ).getPair(address(bana), WETH);
        uint256 liquidity = IERC20(pair).balanceOf(address(this));

        IERC20(pair).approve(UNISWAP_V2_ROUTER, liquidity);
        IUniswapV2Router02(UNISWAP_V2_ROUTER).removeLiquidity(
            address(bana),
            WETH,
            liquidity / 10,
            0,
            0,
            address(this),
            block.timestamp
        );
    }
}
