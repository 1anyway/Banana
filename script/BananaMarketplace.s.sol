// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

import {Script} from "forge-std/Script.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {BananaNFT} from "../contracts/BananaNFT.sol";
import {BananaMarketplace} from "../contracts/BananaMarketplace.sol";

contract BananaMarketplaceScript is Script {
    function run() public {
        vm.broadcast();
        new BananaMarketplace(IERC20(0x0D35548DBD3CC4583A77Be279d54a6Ebf4AEFFE6), BananaNFT(0x1A998FBb431809E913047C154653e5016CABd2F1));
    }
}
