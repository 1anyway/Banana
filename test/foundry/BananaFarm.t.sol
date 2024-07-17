// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {Utils} from "./Utils.sol";
import {BananaNFT} from "../../contracts/BananaNFT.sol";
import {BananaToken} from "../../contracts/BananaToken.sol";
import {BananaFarm} from "../../contracts/BananaFarm.sol";

contract BananaFarmTest is Test {
    BananaFarm internal bananaFarm;
    BananaToken internal bananaToken;
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

        bananaToken = new BananaToken(
            0xcC93A941713e1aA28aDe56a3DB6805F163B10C14
        );
        bananaNFT = new BananaNFT(
            mintInterval,
            whitelistMintTime,
            0xcC93A941713e1aA28aDe56a3DB6805F163B10C14
        );
        bananaFarm = new BananaFarm(address(bananaNFT), address(bananaToken));

        utils = new Utils();
        users = utils.createUsers(5);
        alice = users[0];
        bob = users[1];
    }

    function test_Deployment() public {
        assertEq(bananaFarm.totalStaked(), 0);
        assertEq(bananaFarm.genesisRate(), 0);
        assertEq(bananaFarm.legendRate(), 0);
        assertEq(bananaFarm.rareRate(), 0);
        assertEq(bananaFarm.commonRate(), 0);
        assertEq(address(bananaFarm.bananaNFT()), address(bananaNFT));
        assertEq(address(bananaFarm.bananaToken()), address(bananaToken));
        assertEq(bananaFarm.snapshot(alice, 1), 0);
        assertFalse(bananaFarm.staked(alice, 1));
        assertEq(bananaFarm.tokenRate(1), 0);
    }

    function test_stake() public {
        _mintNFTs();
        bananaNFT.approve(address(bananaFarm), 1);
        assertEq(bananaNFT.balanceOf(alice), 100);
        assertEq(bananaNFT.balanceOf(address(bananaFarm)), 0);
        assertEq(bananaNFT.ownerOf(1), alice);
        bananaFarm.stake(1, 3);
        assertEq(bananaNFT.balanceOf(alice), 99);
        assertEq(bananaNFT.balanceOf(address(bananaFarm)), 1);
        assertEq(bananaNFT.ownerOf(1), address(bananaFarm));
    }

    function test_batchStake() public {
        _mintNFTs();
        bananaNFT.approve(address(bananaFarm), 1);
        uint256[] memory levels = new uint256[](4);
        uint256[] memory tokenIds = new uint256[](4);
        for(uint256 i = 0; i < 4; ++i) {
            levels[i] = i;
            tokenIds[i] = i + 1;
            assertEq(bananaNFT.ownerOf(i + 1), alice);
        }
        assertEq(bananaNFT.balanceOf(alice), 100);
        assertEq(bananaNFT.balanceOf(address(bananaFarm)), 0);
        bananaNFT.setApprovalForAll(address(bananaFarm), true);
        bananaFarm.batchStake(tokenIds, levels);
        assertEq(bananaNFT.balanceOf(alice), 96);
        assertEq(bananaNFT.balanceOf(address(bananaFarm)), 4);
        for(uint256 i = 0; i < 4; ++i) {
            assertEq(bananaNFT.ownerOf(i + 1), address(bananaFarm));
        }
    }

    function test_unstake() public {
        _mintNFTs();
        bananaNFT.approve(address(bananaFarm), 1);
        assertEq(bananaNFT.balanceOf(alice), 100);
        assertEq(bananaNFT.balanceOf(address(bananaFarm)), 0);
        assertEq(bananaNFT.ownerOf(1), alice);
        bananaFarm.stake(1, 3);
        assertEq(bananaNFT.balanceOf(alice), 99);
        assertEq(bananaNFT.balanceOf(address(bananaFarm)), 1);
        assertEq(bananaNFT.ownerOf(1), address(bananaFarm));
        bananaFarm.unstake(1);
        assertEq(bananaNFT.balanceOf(alice), 100);
        assertEq(bananaNFT.balanceOf(address(bananaFarm)), 0);
        assertEq(bananaNFT.ownerOf(1), alice);
    }

    function test_batchUnStake() public {
        _mintNFTs();
        bananaNFT.approve(address(bananaFarm), 1);
        uint256[] memory levels = new uint256[](4);
        uint256[] memory tokenIds = new uint256[](4);
        for(uint256 i = 0; i < 4; ++i) {
            levels[i] = i;
            tokenIds[i] = i + 1;
            assertEq(bananaNFT.ownerOf(i + 1), alice);
        }
        assertEq(bananaNFT.balanceOf(alice), 100);
        assertEq(bananaNFT.balanceOf(address(bananaFarm)), 0);
        bananaNFT.setApprovalForAll(address(bananaFarm), true);
        bananaFarm.batchStake(tokenIds, levels);
        assertEq(bananaNFT.balanceOf(alice), 96);
        assertEq(bananaNFT.balanceOf(address(bananaFarm)), 4);
        for(uint256 i = 0; i < 4; ++i) {
            assertEq(bananaNFT.ownerOf(i + 1), address(bananaFarm));
        }
        bananaFarm.batchUnstake(tokenIds);
        for(uint256 i = 0; i < 4; ++i) {
            assertEq(bananaNFT.ownerOf(i + 1), alice);
        }
        assertEq(bananaNFT.balanceOf(alice), 100);
        assertEq(bananaNFT.balanceOf(address(bananaFarm)), 0);
    }

    function test_claimRewards() public {
        _mintNFTs();
        bananaNFT.approve(address(bananaFarm), 1);
        bananaFarm.stake(1, 3);
        skip(1000000);
        bananaFarm.claimRewards(1);
    }

    function test_batchClaimRewards() public {
        _mintNFTs();
        bananaNFT.approve(address(bananaFarm), 1);
        uint256[] memory levels = new uint256[](4);
        uint256[] memory tokenIds = new uint256[](4);
        for(uint256 i = 0; i < 4; ++i) {
            levels[i] = i;
            tokenIds[i] = i + 1;
        }
        bananaNFT.setApprovalForAll(address(bananaFarm), true);
        bananaFarm.batchStake(tokenIds, levels);
        skip(1000000);
        bananaFarm.batchClaimRewards(tokenIds);
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