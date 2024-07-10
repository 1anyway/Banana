// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

import {Script} from "forge-std/Script.sol";
import {Read} from "../contracts/Read.sol";

contract ReadScript is Script {
    function run() public {
        vm.broadcast();
        new Read(
            0xF7276bA2f6895707fa6884EeF541D8d3Ce6e36f8,
            0xc5747F1Fe0f37099a30555d54A82367199371D81
        );
    }
}
