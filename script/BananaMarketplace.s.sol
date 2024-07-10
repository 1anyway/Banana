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
            IERC20(0x338d96c13AC705B5915891358adF8f5E9b780d18),
            BananaNFT(0x12bD6b752a5361B4F8D8364a705f4fAcf053d448)
        );
    }
}
