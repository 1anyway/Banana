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

    // IERC20 public token;
    // BananaNFT public bananaNFT;
    // bool isFloorSet;
    // uint256 public floorPrice;
    // uint256 public burnRate = 5; // 5%
    
    // struct Listing {
    //     address seller;
    //     uint256 price;
    //     bool listed;
    // }
    
    // mapping(uint256 => Listing) public listings;

    // event Listed(uint256 indexed tokenId, address seller, uint256 price);
    // event Unlisted(uint256 indexed tokenId, address seller);
    // event Purchased(uint256 indexed tokenId, address buyer, uint256 price);

    function setUp() public view {
        bscTestnetFork = vm.createSelectFork(BNB_MAINNET_RPC_URL, blockNum);

        mintInterval = 30;
        whitelistMintTime = 60;

        bananaToken = new BananaToken(1e26);
        bananaNFT = new BananaNFT(mintInterval, bananaToken, whitelistMintTime);
        bananaMarketplace = new BananaMarketplace(bananaToken, bananaNFT);

        utils = new Utils();
        users = utils.createUsers(5);
        alice = users[0];
        bob = users[1];
    }

    function test_Deployment() public {
        assertEq(address(bananaMarketplace.token()), address(bananaToken));
        assertEq(address(bananaMarketplace.bananaNFT()), address(bananaNFT));
        assertFalse(bananaMarketplace.isFloorSet());
        assertEq(bananaMarketplace.floorPrice(), 0);
        assertEq(bananaMarketplace.burnRate(), 5);
    }

    function test_listNFT() public {

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