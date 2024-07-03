// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

import "forge-std/Script.sol";
import {BananaToken} from "../contracts/BananaToken.sol";

contract BananaTokenScript is Script {
    function run() public {
        vm.broadcast();
        new BananaToken(1e26);
    }
}
