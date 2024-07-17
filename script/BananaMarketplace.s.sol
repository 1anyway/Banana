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
            IERC20(0x91d38817206243F40b9C18c658EE9877E20dEC31),
            BananaNFT(0x56986b8ac9B0306B7cA790Dcaa3f3f7A3204D2ef)
        );
    }
}
