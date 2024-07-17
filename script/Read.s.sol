// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

import {Script} from "forge-std/Script.sol";
import {Read} from "../contracts/Read.sol";

contract ReadScript is Script {
    function run() public {
        vm.broadcast();
        new Read(
            0xeA84cCa83478ADE94F06937a917fb64b5BA8b35F,
            0x1de5DBb067353E9D5C287E65d136d4b15C128F62
        );
    }
}
