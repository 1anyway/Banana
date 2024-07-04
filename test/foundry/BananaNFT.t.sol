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
    
    function setUp() public {
        bscTestnetFork = vm.createSelectFork(BNB_MAINNET_RPC_URL, blockNum);

        bananaToken = new BananaToken(1e26);
        bananaNFT = new BananaNFT(30, bananaToken, 30);

        utils = new Utils();
        users = utils.createUsers(5);
        alice = users[0];
        bob = users[1];
    }

    function test_Deployment() public {
        assertEq(address(bananaNFT.token()), address(bananaToken));
        assertEq(bananaNFT.mintPrice(), 0.01 ether);
        assertEq(bananaNFT.mintInterval(), 30);
        assertFalse(bananaNFT._isSaleActive());
        assertEq(bananaNFT._tokenURIs(1), "");
        assertEq(bananaNFT.lastMintTime(alice), 0);
    }

    function test_judgeMint_BeforeMint() public {
        vm.prank(alice);
        assertEq(bananaNFT.judgeMint(), 0);
    }

    function test_judgeMint_AfterMint() public {
        skip(31);
        vm.startPrank(alice);
        bananaNFT.mint("");
        assertEq(bananaNFT.judgeMint(), block.timestamp + 30);
        vm.stopPrank();
    }

    function test_whitelistMint() public {
        bananaNFT.addToWhitelsit(alice);
        vm.prank(alice);
        bananaNFT.mint("");
    }

    function test_publicMint() public {
        skip(31);
        vm.startPrank(alice);
        for (uint256 i = 0; i < 100; ++i) {
            bananaNFT.mint("");
            skip(30);
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
}