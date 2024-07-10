// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

import {Script} from "forge-std/Script.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {BananaNFT} from "../contracts/BananaNFT.sol";
import {BananaMarketplace} from "../contracts/BananaMarketplace.sol";

contract BananaMarketplaceScript is Script {
    function run() public {
        vm.broadcast();
        new BananaMarketplace(
            IERC20(0xF7276bA2f6895707fa6884EeF541D8d3Ce6e36f8),
            BananaNFT(0x5F84ca9c5A1A6965A60279Cfa36949b5fE799DB7)
        );
    }
}
