// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {Utils} from "./Utils.sol";

contract HelpTest is Test {

    function setUp() public {

    }

    function test_convertAddressToBytes_sepolia() public {
        console.log("Sepolia");
        bytes32 x = bytes32(uint256(uint160(0xaa3ED237Fcd07D00C6099C0dAF8fe99948050E99)));
        console.logBytes32(x);
    }

    function test_convertAddressToBytes_arbSepolia() public {
        console.log("ArbSepolia");
        console.logBytes32(bytes32(uint256(uint160(0x71Ef11f9472cC93E7eA683D23F561F412DA71055))));
    }
}