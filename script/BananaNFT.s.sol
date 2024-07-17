// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

import {Script} from "forge-std/Script.sol";
import {BananaNFT} from "../contracts/BananaNFT.sol";

contract BananaNFTScript is Script {
    function run() public {
        vm.broadcast();
        new BananaNFT(
            2 hours,
            24 hours,
            0x162bcf6e6Fc11CE30b3a74aB5Bf6F6fab2D49ec1
        );
    }
}
