// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {Utils} from "./Utils.sol";
import {BananaNFT} from "../../contracts/BananaNFT.sol";
import {BananaToken} from "../../contracts/BananaToken.sol";

contract BananaNFTTest is Test {
    BananaToken internal bananaToken;
    BananaNFT internal bananaNFT;

    Utils internal utils;
    address payable[] internal users;
    address internal alice;
    address internal bob;

    uint256 public bscTestnetFork;
    string public BNB_MAINNET_RPC_URL = vm.envString("BNB_MAINNET_RPC_URL");
    uint256 public constant blockNum = 16449268;
    
    uint256 public mintInterval;
    uint256 public whitelistMintTime;
    function setUp() public {
        bscTestnetFork = vm.createSelectFork(BNB_MAINNET_RPC_URL, blockNum);

        mintInterval = 30;
        whitelistMintTime = 60;

        bananaToken = new BananaToken(1e26);
        bananaNFT = new BananaNFT(mintInterval, bananaToken, whitelistMintTime);

        utils = new Utils();
        users = utils.createUsers(5);
        alice = users[0];
        bob = users[1];
    }

    function test_Deployment() public view {
        assertEq(address(bananaNFT.token()), address(bananaToken));
        assertEq(bananaNFT.mintPrice(), 0.01 ether);
        assertEq(bananaNFT.mintInterval(), mintInterval);
        assertFalse(bananaNFT._isSaleActive());
        assertEq(bananaNFT.endWhitelistMintTime(), block.timestamp + whitelistMintTime);
        assertEq(bananaNFT._tokenURIs(1), "");
        assertEq(bananaNFT.lastMintTime(alice), 0);
    }

    function test_judgeWhitelistMint_BeforeMint() public {
        bananaNFT.addToWhitelsit(alice);
        vm.prank(alice);
        assertEq(bananaNFT.judgeMint(), 0);
    }

    function test_judgeWhitelistMint_AfterMint() public {
        bananaNFT.addToWhitelsit(alice);
        vm.startPrank(alice);
        bananaNFT.mint("");
        assertEq(bananaNFT.judgeMint(), block.timestamp + mintInterval);
        vm.stopPrank();
    }

    function test_judgePublicMint_BeforeMint() public {
        skip(whitelistMintTime);
        vm.prank(alice);
        assertEq(bananaNFT.judgeMint(), 0);
    }

    function test_judgePublicMint_AfterMint() public {
        skip(whitelistMintTime);
        vm.startPrank(alice);
        bananaNFT.mint("");
        assertEq(bananaNFT.judgeMint(), block.timestamp + mintInterval);
        vm.stopPrank();
    }

    function test_whitelistMint() public {
        bananaNFT.addToWhitelsit(alice);
        vm.prank(alice);
        bananaNFT.mint("");
    }

    function test_publicMint() public {
        skip(whitelistMintTime);
        vm.startPrank(alice);
        for (uint256 i = 0; i < 100; ++i) {
            bananaNFT.mint("");
            skip(mintInterval);
        }
    }

    function test_payToMint() public {
        bananaNFT.flipSaleActive();
        vm.startPrank(alice);
        uint256 msgValue = bananaNFT.mintPrice();
        for (uint256 i = 1; i < 100; ++i) {
            bananaNFT.payToMint{value: msgValue}("");
        }
    }

    function test_whitelistMint_Fail_NotWhitelist() public {
        vm.prank(alice);
        vm.expectRevert();
        bananaNFT.mint("Only whitelist user can mint");
    }

    function test_whitelistMint_Fail_NotReachTime() public {
        bananaNFT.addToWhitelsit(alice);
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
}