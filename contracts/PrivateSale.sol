// SPDX-License-Identifier: MIT

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

pragma solidity 0.8.26;

contract PrivateSale {
    uint256 public constant TARGET = 500 ether;
    uint256 public constant MINI_AMOUNT = 0.1 ether;

    address public owner;
    uint256 public totalSold;
    bool public saleActive;
    IERC20 public token;
    
    mapping(address => uint256) public contributions;
    mapping(uint256 => uint256) public limits;

    event TokensPurchased(address indexed buyer, uint256 amount);
    event TokensClaimed(address indexed claimer, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor(address _token) {
        owner = msg.sender;
        token = IERC20(_token);
        saleActive = true;
        limits[1] = 1 ether;   // Limit for tier 1
        limits[2] = 5 ether;   // Limit for tier 2
        limits[3] = 10 ether;  // Limit for tier 3
        limits[4] = 20 ether;  // Limit for tier 4
    }

    receive() external payable {
        revert("Direct sending ETHs disallowed");
    }

    function buyTokens(uint256 tier) external payable {
        require(saleActive, "Sale is not active");
        require(tier >= 1 && tier <= 4, "Invalid tier");
        require(msg.value >= MINI_AMOUNT, "Must exceed the minimum amount");
        require(msg.value <= limits[tier], "Exceeds tier limit");
        require(msg.value > limits[tier -1], "Should greater than last tier");
        require(totalSold + msg.value <= TARGET, "Exceeds target");
        contributions[msg.sender] += msg.value;
        totalSold += msg.value;
        emit TokensPurchased(msg.sender, msg.value);
    }

    function claimTokens() external {
        uint256 contribution = contributions[msg.sender];
        require(contribution > 0, "No contributions");
        require(!saleActive, "Sale is still active");
        
        uint256 tokenAmount = _getTokenAmount(contribution);
        contributions[msg.sender] = 0;
        bool success = token.transfer(msg.sender, tokenAmount);
        require(success, "Token transfer failed");
        emit TokensClaimed(msg.sender, tokenAmount);
    }

    function withdrawETH(address treasury, uint256 ethAmount) external onlyOwner {
        require(address(this).balance >= ethAmount, "Insufficient balance");
        (bool success, ) = payable(treasury).call{value: ethAmount}("");
        require(success, "Payment is not successful");
    }

    function withdrawToken(address treasury, uint256 tokenAmount) external onlyOwner {
        require(token.balanceOf(address(this)) >= tokenAmount, "Insufficient token balance");
        bool success = token.transfer(treasury, tokenAmount);
        require(success, "Token transfer failed");
    }

    function endSale() external onlyOwner {
        saleActive = false;
    }

    function getETHBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function getTokenBalance() external view returns (uint256) {
        return token.balanceOf(address(this));
    }

    function _getTokenAmount(uint256 contribution) internal pure returns (uint256) {
        return contribution * 1000; // Example: 1 ETH = 1000 Token
    }
}
