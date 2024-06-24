// SPDX-License-Identifier: MIT

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

pragma solidity 0.8.26;

contract ERC20Token is ERC20 {

    constructor(uint256 initialSupply) ERC20("Example Token", "EXT"){
        _mint(msg.sender, initialSupply);
    }
}