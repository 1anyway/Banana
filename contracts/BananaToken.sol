/*
 * 
🍌 Website:  https://bananaeth.app/
🍌 Telegram: https://t.me/Banana_Banana_coin
🍌 Twitter:  https://x.com/Banana_coin1
 */
// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {console} from "forge-std/console.sol";
import {IUniswapV2Router02} from "./interfaces/IUniswapV2Router02.sol";
import {IUniswapV2Pair} from "./interfaces/IUniswapV2Pair.sol";
import {IUniswapV2Factory} from "./interfaces/IUniswapV2Factory.sol";

contract BananaToken is ERC20, Ownable {
    //BSC: 0x10ED43C718714eb63d5aA57B78B54704E256024E
    //MA: 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
    //BSC testnet: 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
    address private constant DEAD = address(0xdead);
    // address private constant UNISWAP_V2_ROUTER =
    //     0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint256 private taxRate = 5;
    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    address private marketingWallet;
    bool private tradingPoolCreated;
    bool private inSwap = false;
    uint256 private launchBlock;

    mapping(address => bool) private _isExcludedFromFees;

    event ExcludeFromFees(address indexed account, bool isExcluded);

    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor(
        address _marketingWallet
    ) ERC20("BananaToken", "BANA") Ownable(msg.sender) {
        marketingWallet = _marketingWallet;

        _isExcludedFromFees[owner()] = true;
        _isExcludedFromFees[DEAD] = true;
        _isExcludedFromFees[address(this)] = true;
        _isExcludedFromFees[marketingWallet] = true;
        _isExcludedFromFees[address(0)] = true;

        uniswapV2Router = IUniswapV2Router02(
            0x10ED43C718714eb63d5aA57B78B54704E256024E
        );
        _approve(
            address(this),
            0x10ED43C718714eb63d5aA57B78B54704E256024E,
            type(uint256).max
        );
        _mint(msg.sender, 21e25);
    }

    receive() external payable {}

    // function createTradingPool() external onlyOwner {
    //     require(!tradingPoolCreated, "trading pool is already created!");
    //     uniswapV2Router = IUniswapV2Router02(
    //         0x10ED43C718714eb63d5aA57B78B54704E256024E
    //     );
    //     uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(
    //         address(this),
    //         uniswapV2Router.WETH()
    //     );
    //     _approve(address(this), address(uniswapV2Router), type(uint256).max);
    //     tradingPoolCreated = true;
    // }

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
        if (
            (!_isExcludedFromFees[from] && !_isExcludedFromFees[to]) &&
            (from == uniswapV2Pair || to == uniswapV2Pair)
        ) {
            _spendAllowance(from, msg.sender, value);
            _transferWithTax(from, to, value);
        } else {
            super.transferFrom(from, to, value);
        }
        return true;
    }

    function triggerSwap() external {
        require(
            msg.sender == marketingWallet || msg.sender == owner(),
            "Only fee receiver can trigger"
        );
        uint256 contractTokenBalance = balanceOf(address(this));

        swapTokensToETH(contractTokenBalance);
        uint256 contractETHBalance = address(this).balance;
        if (contractETHBalance > 0) {
            sendETH(payable(marketingWallet), contractETHBalance);
        }
    }

    function setMkt(address payable _marketingWallet) external onlyOwner {
        marketingWallet = _marketingWallet;
    }

    function withdrawETH() external {
        require(msg.sender == marketingWallet, "Only fee receiver can trigger");
        payable(marketingWallet).transfer(address(this).balance);
    }

    function withdrawErrorToken(address _address) external {
        require(msg.sender == marketingWallet, "Only fee receiver can trigger");
        IERC20(_address).transfer(
            marketingWallet,
            IERC20(_address).balanceOf(address(this))
        );
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

    function isExcludedFromFees(address account) external view returns (bool) {
        return _isExcludedFromFees[account];
    }

    function sendETH(address payable recipient, uint256 amount) private {
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

    function _transferWithTax(
        address from,
        address to,
        uint256 amount
    ) private {
        uint256 taxAmount = (amount * taxRate) / 100;
        uint256 transferAmount = amount - taxAmount;
        super._transfer(from, address(this), taxAmount);

        uint256 contractTokenBalance = balanceOf(address(this));
        bool canSwap = contractTokenBalance > 0;
        if (canSwap && tradingPoolCreated && !inSwap && from != uniswapV2Pair) {
            swapTokensToETH(contractTokenBalance);
            uint256 newBalance = address(this).balance;
            if (newBalance > 0) {
                sendETH(payable(marketingWallet), newBalance);
            }
        }
        super._transfer(from, to, transferAmount);
    }

    function swapTokensToETH(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }
}
