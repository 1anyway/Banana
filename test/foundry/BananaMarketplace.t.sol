// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {Utils} from "./Utils.sol";
import {BananaNFT} from "../../contracts/BananaNFT.sol";
import {BananaToken} from "../../contracts/BananaToken.sol";
import {BananaMarketplace} from "../../contracts/BananaMarketplace.sol";

contract BananaNFTTest is Test {
    BananaMarketplace internal bananaMarketplace;
    BananaToken internal bananaToken;
    BananaNFT internal bananaNFT;

    Utils internal utils;
    address payable[] internal users;
    address internal alice;
    address internal bob;

    uint256 public bscFork;
    string public BNB_MAINNET_RPC_URL = vm.envString("BNB_MAINNET_RPC_URL");
    uint256 public constant blockNum = 20274555;

    uint256 public mintInterval;
    uint256 public whitelistMintTime;

    function setUp() public {
        bscFork = vm.createSelectFork(BNB_MAINNET_RPC_URL, blockNum);

        mintInterval = 30;
        whitelistMintTime = 60;

        bananaToken = new BananaToken(
            0xcC93A941713e1aA28aDe56a3DB6805F163B10C14
        );
        bananaNFT = new BananaNFT(
            mintInterval,
            whitelistMintTime,
            0xcC93A941713e1aA28aDe56a3DB6805F163B10C14
        );
        bananaMarketplace = new BananaMarketplace(bananaToken, bananaNFT);

        utils = new Utils();
        users = utils.createUsers(5);
        alice = users[0];
        bob = users[1];
    }

    function test_Deployment() public view {
        assertEq(address(bananaMarketplace.token()), address(bananaToken));
        assertEq(address(bananaMarketplace.bananaNFT()), address(bananaNFT));
        assertFalse(bananaMarketplace.isFloorSet());
        assertEq(bananaMarketplace.floorPrice(), 0);
        assertEq(bananaMarketplace.burnRate(), 3);
    }

    function test_listNFT() public {
        _mintNFTs();
        bananaNFT.approve(address(bananaMarketplace), 1);
        bananaMarketplace.listNFT(1, 1e20);
    }

    function test_buyNFT() public {
        _mintNFTs();
        bananaNFT.approve(address(bananaMarketplace), 1);
        bananaMarketplace.listNFT(1, 1e20);
        vm.stopPrank();
        deal(address(bananaToken), bob, 1e22);
        vm.prank(bob);
        bananaToken.approve(address(bananaMarketplace), 1e22);
        vm.prank(bob);
        bananaMarketplace.buyNFT(1);
    }

    function test_buyNFT_SameOne_Fail() public {
        _mintNFTs();
        bananaNFT.approve(address(bananaMarketplace), 1);
        bananaMarketplace.listNFT(1, 1e20);
        deal(address(bananaToken), alice, 1e22);
        bananaToken.approve(address(bananaMarketplace), 1e22);
        vm.expectRevert("You are the seller");
        bananaMarketplace.buyNFT(1);
    }

    function test_buyNFT_NotList_Fail() public {
        _mintNFTs();
        bananaNFT.approve(address(bananaMarketplace), 1);
        bananaMarketplace.listNFT(1, 1e20);
        vm.stopPrank();
        deal(address(bananaToken), bob, 1e22);
        vm.prank(bob);
        bananaToken.approve(address(bananaMarketplace), 1e22);
        vm.prank(bob);
        vm.expectRevert("Not listed");
        bananaMarketplace.buyNFT(200);
    }

    function test_setFloorPriceBuyNFT_Success() public {
        bananaMarketplace.setFloorPrice(2e20);
        _mintNFTs();
        bananaNFT.approve(address(bananaMarketplace), 1);
        bananaMarketplace.listNFT(1, 2e20);
        vm.stopPrank();
        deal(address(bananaToken), bob, 1e22);
        vm.prank(bob);
        bananaToken.approve(address(bananaMarketplace), 1e22);
        vm.prank(bob);
        bananaMarketplace.buyNFT(1);
    }

    function test_setFloorPriceListNFT_LessThanFloorPrice_Fail() public {
        assertFalse(bananaMarketplace.isFloorSet());
        bananaMarketplace.toggleIsFloorPrice();
        assertTrue(bananaMarketplace.isFloorSet());
        bananaMarketplace.setFloorPrice(2e20);
        _mintNFTs();
        bananaNFT.approve(address(bananaMarketplace), 1);
        vm.expectRevert("List price must greater than floor price");
        bananaMarketplace.listNFT(1, 1e20);
        vm.stopPrank();
    }

    function test_unlistNFT() public {
        _mintNFTs();
        bananaNFT.approve(address(bananaMarketplace), 1);
        bananaMarketplace.listNFT(1, 1e20);
        bananaMarketplace.unlistNFT(1);
        vm.stopPrank();
    }

    function test_setFloorPrice() public {
        bananaMarketplace.setFloorPrice(2e20);
        assertEq(bananaMarketplace.floorPrice(), 2e20);
    }

    function test_setFloorPrice_NotOwnerCall_Fail() public {
        vm.prank(alice);
        vm.expectRevert(
            abi.encodeWithSignature(
                "OwnableUnauthorizedAccount(address)",
                alice
            )
        );
        bananaMarketplace.setFloorPrice(2e20);
    }

    function test_setBurnRate() public {
        assertEq(bananaMarketplace.burnRate(), 3);
        bananaMarketplace.setBurnRate(10);
        assertEq(bananaMarketplace.burnRate(), 10);
    }

    function test_setBurnRate_NotOwnerCall_Fail() public {
        vm.prank(alice);
        vm.expectRevert(
            abi.encodeWithSignature(
                "OwnableUnauthorizedAccount(address)",
                alice
            )
        );
        bananaMarketplace.setBurnRate(10);
    }

    function test_toggleIsFloorPrice() public {
        assertFalse(bananaMarketplace.isFloorSet());
        bananaMarketplace.toggleIsFloorPrice();
        assertTrue(bananaMarketplace.isFloorSet());
    }

    function test_toggleIsFloorPrice_NotOwnerCall_Fail() public {
        vm.prank(alice);
        vm.expectRevert(
            abi.encodeWithSignature(
                "OwnableUnauthorizedAccount(address)",
                alice
            )
        );
        bananaMarketplace.toggleIsFloorPrice();
    }

    function test_setBurnRate_GreaterThan20_Fail() public {
        vm.expectRevert("Invalid burnRate");
        bananaMarketplace.setBurnRate(20);
    }

    function test_withdrawBurnedTokens() public {
        _mintNFTs();
        bananaNFT.approve(address(bananaMarketplace), 1);
        bananaMarketplace.listNFT(1, 1e20);
        vm.stopPrank();
        deal(address(bananaToken), bob, 1e22);
        uint256 aliceBalanceBefore = bananaToken.balanceOf(alice);
        vm.prank(bob);
        bananaToken.approve(address(bananaMarketplace), 1e22);
        vm.prank(bob);
        bananaMarketplace.buyNFT(1);
        bananaMarketplace.withdrawBurnedTokens();
        uint256 aliceBalanceAfter = bananaToken.balanceOf(alice);
        uint256 difference = (1e20 * bananaMarketplace.burnRate()) / 100;
        assertEq(aliceBalanceBefore, 0);
        assertEq(aliceBalanceAfter, 1e20 - difference);
    }

    function test_withdrawBurnedTokens_NotOwnerCall_Fail() public {
        vm.prank(alice);
        vm.expectRevert(
            abi.encodeWithSignature(
                "OwnableUnauthorizedAccount(address)",
                alice
            )
        );
        bananaMarketplace.withdrawBurnedTokens();
    }

    function _mintNFTs() internal {
        bananaNFT.addToWhitelist(alice);
        vm.startPrank(alice);
        skip(whitelistMintTime);
        for (uint256 i = 0; i < 100; ++i) {
            bananaNFT.mint("");
            skip(mintInterval);
        }
    }
}
