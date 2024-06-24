// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

import "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import "./Utils.sol";
import {PrivateSale} from "../../contracts/PrivateSale.sol";
import {ERC20Token} from "../../contracts/ERC20Token.sol";

contract PrivateSaleTest is Test {
    ERC20Token internal erc20Token;
    PrivateSale internal privateSale;

    Utils internal utils;
    address payable[] internal users;
    address internal alice;
    address internal bob;

    uint256 public mainnetFork;
    string public MAINNET_RPC_URL = vm.envString("MAINNET_RPC_URL");
    uint256 public constant blockNum = 16449268;

    function setUp() public {
        mainnetFork = vm.createSelectFork(MAINNET_RPC_URL, blockNum);
        erc20Token = new ERC20Token(1e6 ether);
        privateSale = new PrivateSale(address(erc20Token));

        utils = new Utils();
        users = utils.createUsers(5);
        alice = users[0];
        bob = users[1];
    }

    function test_Deployment() public {
        assertEq(privateSale.TARGET(), 500 ether);
        assertEq(privateSale.MINI_AMOUNT(), 0.1 ether);
        assertEq(privateSale.owner(), address(this));
        assertEq(privateSale.totalSold(), 0);
        assertTrue(privateSale.saleActive());
        assertEq(address(privateSale.token()), address(erc20Token));
        assertEq(privateSale.contributions(address(this)), 0);
        assertEq(privateSale.limits(0), 0 ether);
        assertEq(privateSale.limits(1), 1 ether);
        assertEq(privateSale.limits(2), 5 ether);
        assertEq(privateSale.limits(3), 10 ether);
        assertEq(privateSale.limits(4), 20 ether);
    }

    function test_buyTokens() public {
        vm.prank(alice);
        uint256 tier;
        tier = bound(tier, 1, 4);
        uint256 msgValue;
        if (tier == 1) {
            msgValue = bound(msgValue, 0.1 ether, 1 ether);
        }
        if (tier == 2) {
            msgValue = bound(msgValue, 1.1 ether, 5 ether);
        }
        if (tier == 3) {
            msgValue = bound(msgValue, 5.1 ether, 10 ether);
        }
        if (tier == 4) {
            msgValue = bound(msgValue, 10.1 ether, 20 ether);
        }
        privateSale.buyTokens{value: msgValue}(tier);
    }

    function test_claimTokens() public {
        deal(alice, 600 ether);
        vm.startPrank(alice);
        for (uint256 i = 0; i < 25; ++i) {
            privateSale.buyTokens{value: 20 ether}(4);
        }
        vm.stopPrank();
        privateSale.endSale();
        assertFalse(privateSale.saleActive());
        erc20Token.transfer(address(privateSale), 1e6 ether);
        vm.prank(alice);
        privateSale.claimTokens();
        uint256 aliceBalance = erc20Token.balanceOf(alice);
        uint256 contractBalance = erc20Token.balanceOf(address(privateSale));
        assertEq(aliceBalance, 500000 ether);
        assertEq(contractBalance, 500000 ether);
        uint256 bobTokenBalanceBefore = erc20Token.balanceOf(bob);
        privateSale.withdrawToken(bob, contractBalance);
        uint256 bobTokenBalanceAfter = erc20Token.balanceOf(bob);
        assertEq(bobTokenBalanceBefore, 0);
        assertEq(bobTokenBalanceAfter, contractBalance);
        uint256 bobETHBalanceBefore = bob.balance;
        privateSale.withdrawETH(bob, address(privateSale).balance);
        uint256 bobETHBalanceAfter = bob.balance;
        assertEq(bobETHBalanceAfter, bobETHBalanceBefore + 500 ether);
    }
}