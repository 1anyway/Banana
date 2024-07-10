// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

import {Script} from "forge-std/Script.sol";
import {Read} from "../contracts/Read.sol";

contract ReadScript is Script {
    function run() public {
        vm.broadcast();
        new Read(
            0x338d96c13AC705B5915891358adF8f5E9b780d18,
            0x7c11cf8B337246317D55Ba2eBB5868422001b8E5
        );
    }
}
