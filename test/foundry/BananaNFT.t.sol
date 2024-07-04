// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

import "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import "./Utils.sol";
import {BananaNFT} from "../../contracts/BananaNFT.sol";
import {BananaToken} from "../../contracts/BananaToken.sol";

contract BananaNFTTest is Test {
    BananaToken internal bananaToken;
    BananaNFT internal bananaNFT;
    
    function setUp() public {

        bananaToken = new bananaToken(1e26);
        bananaNFT = new BananaNFT(30, bananaToken);
    }

    function test_Deployment() public {
        assertEq(bananaNFT._tokenIdCounter(), 0);
        assertEq(address(bananaNFT.token()), address(0));
        assertEq(bananaNFT.mintPrice(), 0.01 ether);
        assertEq(bananaNFT.mintInterval(), 0);
        assertEq(bananaNFT.saleEndTime(), 0);
        assertFalse(bananaNFT._isSaleActive());
        assertEq(bananaNFT._tokenURIs(1), "");
        assertEq(bananaNFT.lastMintTime(address(this)), 0);

    }

    function test_judgeMint() public {

    }

    function test_mint() public {

    }
    

}