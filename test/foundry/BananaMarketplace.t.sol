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

    uint256 public bscTestnetFork;
    string public BNB_MAINNET_RPC_URL = vm.envString("BNB_MAINNET_RPC_URL");
    uint256 public constant blockNum = 16449268;

    uint256 public mintInterval;
    uint256 public whitelistMintTime;

    function setUp() public {
        bscTestnetFork = vm.createSelectFork(BNB_MAINNET_RPC_URL, blockNum);

        mintInterval = 30;
        whitelistMintTime = 60;

        bananaToken = new BananaToken(1e26, address(this));
        bananaNFT = new BananaNFT(
            mintInterval,
            bananaToken,
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
        assertEq(bananaMarketplace.burnRate(), 5);
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

    function _mintNFTs() internal {
        bananaNFT.addToWhitelsit(alice);
        vm.startPrank(alice);
        skip(whitelistMintTime);
        for (uint256 i = 0; i < 100; ++i) {
            bananaNFT.mint("");
            skip(mintInterval);
        }
    }
}
