// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

import {Script} from "forge-std/Script.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {BananaNFT} from "../contracts/BananaNFT.sol";

contract BananaNFTScript is Script {
    function run() public {
        vm.broadcast();
        new BananaNFT(
            30,
            IERC20(0x0D35548DBD3CC4583A77Be279d54a6Ebf4AEFFE6),
            30,
            0xcC93A941713e1aA28aDe56a3DB6805F163B10C14
        );
    }
}
