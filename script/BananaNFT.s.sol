// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

import {Script} from "forge-std/Script.sol";
import {BananaNFT} from "../contracts/BananaNFT.sol";

contract BananaNFTScript is Script {
    function run() public {
        vm.broadcast();
        new BananaNFT(
            30,
            30,
            0xbaE311B8d7ae35e5c261A5873acE96991c5573cD
        );
    }
}
