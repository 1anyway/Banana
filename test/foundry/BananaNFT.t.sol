// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {Utils} from "./Utils.sol";
import {BananaNFT} from "../../contracts/BananaNFT.sol";

contract BananaNFTTest is Test {
    BananaNFT internal bananaNFT;

    Utils internal utils;
    address payable[] internal users;
    address internal alice;
    address internal bob;

    uint256 public bscFork;
    string public BNB_MAINNET_RPC_URL = vm.envString("BNB_MAINNET_RPC_URL");
    uint256 public constant blockNum = 40406990;

    uint256 public mintInterval;
    uint256 public whitelistMintTime;
    function setUp() public {
        bscFork = vm.createSelectFork(BNB_MAINNET_RPC_URL, blockNum);

        mintInterval = 30;
        whitelistMintTime = 60;

        bananaNFT = new BananaNFT(
            mintInterval,
            whitelistMintTime,
            0xcC93A941713e1aA28aDe56a3DB6805F163B10C14
        );

        utils = new Utils();
        users = utils.createUsers(5);
        alice = users[0];
        bob = users[1];
    }

    function test_Deployment() public view {
        assertEq(bananaNFT.mintPrice(), 0.03 ether);
        assertEq(bananaNFT.mintInterval(), mintInterval);
        assertFalse(bananaNFT._isSaleActive());
        assertEq(
            bananaNFT.endWhitelistMintTime(),
            block.timestamp + whitelistMintTime
        );
        assertEq(bananaNFT._tokenURIs(1), "");
        assertEq(bananaNFT.lastMintTime(alice), 0);
    }

    function test_whitelistMint() public {
        bananaNFT.addToWhitelist(alice);
        vm.prank(alice);
        bananaNFT.mint("");
    }

    function test_publicMint() public {
        skip(whitelistMintTime);
        assertEq(bananaNFT.currentTokenId(), 0);
        vm.startPrank(alice);
        for (uint256 i = 0; i < 100; ++i) {
            bananaNFT.mint("");
            skip(mintInterval);
        }
        assertEq(bananaNFT.currentTokenId(), 100);
    }

    function test_payToMint() public {
        bananaNFT.flipSaleActive();
        deal(alice, 1e20);
        assertEq(bananaNFT.currentTokenId(), 0);
        vm.startPrank(alice);
        uint256 msgValue = bananaNFT.mintPrice();
        for (uint256 i = 0; i < 100; ++i) {
            bananaNFT.payToMint{value: msgValue}("");
        }
        assertEq(bananaNFT.currentTokenId(), 100);
    }

    function test_whitelistMint_Fail_NotWhitelist() public {
        vm.prank(alice);
        vm.expectRevert();
        bananaNFT.mint("Only whitelist user can mint");
    }

    function test_whitelistMint_Fail_NotReachTime() public {
        bananaNFT.addToWhitelist(alice);
        vm.prank(alice);
        bananaNFT.mint("");
        vm.expectRevert();
        bananaNFT.mint("Not reach mint time");
    }

    function test_publicMint_Fail_NotReachTime() public {
        skip(whitelistMintTime);
        vm.prank(alice);
        bananaNFT.mint("");
        vm.expectRevert();
        bananaNFT.mint("Not reach mint time");
    }

    function test_addToWhitelist() public {
        assertFalse(bananaNFT.whitelist(alice));
        bananaNFT.addToWhitelist(alice);
        assertTrue(bananaNFT.whitelist(alice));
    }

    function test_addToWhitelist_NotOwnerCall_Fail() public {
        assertFalse(bananaNFT.whitelist(alice));
        vm.prank(alice);
        vm.expectRevert(
            abi.encodeWithSignature(
                "OwnableUnauthorizedAccount(address)",
                alice
            )
        );
        bananaNFT.addToWhitelist(alice);
        assertFalse(bananaNFT.whitelist(alice));
    }

    function test_setMintInterval() public {
        assertEq(bananaNFT.mintInterval(), 30);
        bananaNFT.setMintInterval(3600);
        assertEq(bananaNFT.mintInterval(), 3600);
    }

    function test_setMintInterval_NotOwnerCall_Fail() public {
        assertEq(bananaNFT.mintInterval(), 30);
        vm.prank(alice);
        vm.expectRevert(
            abi.encodeWithSignature(
                "OwnableUnauthorizedAccount(address)",
                alice
            )
        );
        bananaNFT.setMintInterval(3600);
        assertEq(bananaNFT.mintInterval(), 30);
    }

    function test_flipSaleActive() public {
        assertFalse(bananaNFT._isSaleActive());
        bananaNFT.flipSaleActive();
        assertTrue(bananaNFT._isSaleActive());
        bananaNFT.flipSaleActive();
        assertFalse(bananaNFT._isSaleActive());
    }

    function test_flipSaleActive_NotOwnerCall_Fail() public {
        assertFalse(bananaNFT._isSaleActive());
        vm.prank(alice);
        vm.expectRevert(
            abi.encodeWithSignature(
                "OwnableUnauthorizedAccount(address)",
                alice
            )
        );
        bananaNFT.flipSaleActive();
        assertFalse(bananaNFT._isSaleActive());
    }

    function test_setMintPrice() public {
        assertEq(bananaNFT.mintPrice(), 3e16);
        bananaNFT.setMintPrice(1e16);
        assertEq(bananaNFT.mintPrice(), 1e16);
    }

    function test_setMintPrice_NotOwnerCall_Fail() public {
        assertEq(bananaNFT.mintPrice(), 3e16);
        vm.prank(alice);
        vm.expectRevert(
            abi.encodeWithSignature(
                "OwnableUnauthorizedAccount(address)",
                alice
            )
        );
        bananaNFT.setMintPrice(1e16);
        assertEq(bananaNFT.mintPrice(), 3e16);
    }
}
