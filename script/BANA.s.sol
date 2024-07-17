// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

import {Script} from "forge-std/Script.sol";
import {BANA} from "../contracts/BANA.sol";

contract BANAScript is Script {
    function run() public {
        vm.broadcast();
        new BANA();
    }
}
