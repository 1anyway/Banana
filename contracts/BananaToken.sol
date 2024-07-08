// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IUniswapV2Router02} from "./interfaces/IUniswapV2Router02.sol";
import {IUniswapV2Pair} from "./interfaces/IUniswapV2Pair.sol";
import {IUniswapV2Factory} from "./interfaces/IUniswapV2Factory.sol";

contract BananaToken is ERC20, Ownable {
    //BSC: 0x10ED43C718714eb63d5aA57B78B54704E256024E
    //MA: 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
    address public constant DEAD = address(0xdead);
    address public constant UNISWAP_V2_ROUTER =
        0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint256 public taxRate = 5;
    IUniswapV2Router02 public immutable uniswapV2Router;
    address public uniswapV2Pair;
    address private immutable marketingWallet;
    bool private swapping;
    uint256 private launchBlock;

    mapping(address => bool) private _isExcludedFromFees;

    event ExcludeFromFees(address indexed account, bool isExcluded);

    constructor(
        uint256 initialSupply,
        address _marketingWallet
    ) ERC20("BananaToken", "BANA") Ownable(msg.sender) {
        marketingWallet = _marketingWallet;
        launchBlock = block.number;
        uniswapV2Router = IUniswapV2Router02(UNISWAP_V2_ROUTER);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(
            address(this),
            uniswapV2Router.WETH()
        );
        _approve(address(this), address(DEAD), type(uint256).max);
        _isExcludedFromFees[owner()] = true;
        _isExcludedFromFees[DEAD] = true;
        _isExcludedFromFees[address(this)] = true;

        _mint(msg.sender, initialSupply);
    }

    receive() external payable {}

    function sendETH(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function transfer(
        address to,
        uint256 value
    ) public override returns (bool) {
        if (
            (!_isExcludedFromFees[msg.sender] && !_isExcludedFromFees[to]) &&
            (msg.sender == uniswapV2Pair || to == uniswapV2Pair)
        ) {
            _transferWithTax(msg.sender, to, value);
        } else {
            super.transfer(to, value);
        }
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public override returns (bool) {
        if (!_isExcludedFromFees[from] && !_isExcludedFromFees[to]) {
            _spendAllowance(from, msg.sender, value);
            _transferWithTax(from, to, value);
        } else {
            super.transferFrom(from, to, value);
        }
        return true;
    }

    function _transferWithTax(
        address from,
        address to,
        uint256 amount
    ) private {
        uint256 taxAmount = (amount * taxRate) / 100;
        uint256 transferAmount = amount - taxAmount;
        super._transfer(from, marketingWallet, taxAmount);
        if (block.number <= launchBlock + 5000) {
            uint256 contractTokenBalance = balanceOf(address(this));

            bool canSwap = contractTokenBalance > 0;

            if (
                canSwap &&
                !swapping &&
                from != uniswapV2Pair
            ) {
                swapping = true;

                address[] memory path = new address[](2);
                path[0] = address(this);
                path[1] = uniswapV2Router.WETH();

                uniswapV2Router
                    .swapExactTokensForETHSupportingFeeOnTransferTokens(
                        contractTokenBalance,
                        0, // accept any amount of ETH
                        path,
                        address(this),
                        block.timestamp
                    );

                uint256 newBalance = address(this).balance;

                if (newBalance > 0) {
                    sendETH(payable(marketingWallet), newBalance);
                }

                swapping = false;
            }
        }
        super._transfer(from, to, transferAmount);
    }

    function isExcludedFromFees(address account) public view returns (bool) {
        return _isExcludedFromFees[account];
    }

    function setTaxRate(uint256 _taxRate) external onlyOwner {
        require(_taxRate < 20, "Invalid taxRate");
        taxRate = _taxRate;
    }

    function excludeFromFees(
        address account,
        bool excluded
    ) external onlyOwner {
        _isExcludedFromFees[account] = excluded;
        emit ExcludeFromFees(account, excluded);
    }
}
