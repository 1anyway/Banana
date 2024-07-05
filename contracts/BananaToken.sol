// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IUniswapV2Router02} from "./interfaces/IUniswapV2Router02.sol";
import {IUniswapV2Pair} from "./interfaces/IUniswapV2Pair.sol";
import {IUniswapV2Factory} from "./interfaces/IUniswapV2Factory.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract BananaToken is ERC20, Ownable {
    address private constant deadAddress = address(0xdead);

    uint256 public taxMultiplier;


    uint256 public taxRate = 5;
    IUniswapV2Router02 public immutable _uniswapV2Router;

    mapping(address => bool) private _isExcludedFromFees;

    event ExcludeFromFees(address indexed account, bool isExcluded);

    constructor(
        uint256 initialSupply
    ) ERC20("BananaToken", "BANANA") Ownable(msg.sender) {
        _mint(msg.sender, initialSupply);

        _approve(address(this), address(deadAddress), type(uint256).max);
    }

    function transfer(
        address to,
        uint256 value
    ) public override returns (bool) {
        if (!_isExcludedFromFees[msg.sender] && !_isExcludedFromFees[to]) {
            uint256 tax = (value * 5) / 100;
            value = tax - value;
            bool success = super.transfer(deadAddress, tax);
            require(success,"tax fee transfer failed!");
        }
        return super.transfer(to, value);
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public override returns (bool) {
        if (!_isExcludedFromFees[to] && !_isExcludedFromFees[from]) {
            uint256 tax = (value * 5) / 100;
            value -= tax;
            bool success = super.transferFrom(from, deadAddress, tax);
            require(success,"tax fee transfer failed!");
        }
        return super.transferFrom(from, to, value);
    }

    function setTaxRate(uint256 _taxRate) external onlyOwner {
        require(_taxRate < 20, "Invalid taxRate");
        taxRate = _taxRate;
    }

    function excludeFromFees(address account, bool excluded) external onlyOwner {
        _isExcludedFromFees[account] = excluded;
        emit ExcludeFromFees(account, excluded);
    }
}
