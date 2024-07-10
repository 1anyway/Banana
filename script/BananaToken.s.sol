// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

import {Script} from "forge-std/Script.sol";
import {BananaToken} from "../contracts/BananaToken.sol";

contract BananaTokenScript is Script {
    function run() public {
        vm.broadcast();
        new BananaToken(0xbaE311B8d7ae35e5c261A5873acE96991c5573cD);
    }
}
