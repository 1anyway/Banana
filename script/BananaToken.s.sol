// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

import {Script} from "forge-std/Script.sol";
import {BananaToken} from "../contracts/BananaToken.sol";

contract BananaTokenScript is Script {
    function run() public {
        vm.broadcast();
        new BananaToken(0xcC93A941713e1aA28aDe56a3DB6805F163B10C14);
    }
}
