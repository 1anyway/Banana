// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20} from "@openzeppelin/contracts/access/Ownable.sol";

contract BananaToken is ERC20, Ownable {
    constructor(uint256 initialSupply) ERC20("BananaToken", "BANANA") Ownable(msg.sender) {
        _mint(msg.sender, initialSupply);
    }
}
