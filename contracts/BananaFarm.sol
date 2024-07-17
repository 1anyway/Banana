// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract BananaFarm is IERC721Receiver, Ownable, ReentrancyGuard {
    uint256 public totalStaked;
    uint256 public genesisRate;
    uint256 public legendRate;
    uint256 public rareRate;
    uint256 public commonRate;
    IERC721 public bananaNFT;
    IERC20  public bananaToken;
    mapping(address => mapping(uint256 => uint256)) public snapshot;
    mapping(address => mapping(uint256 => bool)) public staked;
    mapping(uint256 => uint256) public tokenRate;

    event Staked(address staker, uint256 tokenId, bool staked);
    event Unstaked(address staker, uint256 tokenId, bool staked);
    event RewardsClaimed(address staker, uint256 rewards, uint256 timestamp);

    constructor(address _bananaNFT, address _bananaToken) Ownable(msg.sender) {
        bananaNFT = IERC721(_bananaNFT);
        bananaToken = IERC20(_bananaToken);
    }

    function stake(uint256 tokenId, uint256 t) public nonReentrant {
        _stake(tokenId, t);
    }

    function batchStake(uint256[] memory tokenIds, uint256[] memory levels) public nonReentrant {
        require(tokenIds.length > 0, "");
        require(levels.length == tokenIds.length, "");
        for (uint256 i = 0; i < tokenIds.length; ++i) {
            _stake(tokenIds[i], levels[i]);
        }
    }

    function unstake(uint256 tokenId) public nonReentrant {
        claimRewards(tokenId);
        _unstake(tokenId);
    }

    function batchUnstake(uint256[] memory tokenIds) public nonReentrant {
        require(tokenIds.length > 0, "");
        batchClaimRewards(tokenIds);
        for (uint256 i = 0; i < tokenIds.length; ++i) {
            _unstake(tokenIds[i]);
        }
    }

    function claimRewards(uint256 tokenId) public {
        uint256 rewards = _updateRewards(tokenId);
        bananaToken.transfer(msg.sender, rewards);
        emit RewardsClaimed(msg.sender, rewards, block.timestamp);
    }

    function batchClaimRewards(uint256[] memory tokenIds) public {
        require(tokenIds.length > 0, "");
        uint256 rewards;
        for (uint256 i = 0; i < tokenIds.length; ++i) {
            rewards += _updateRewards(tokenIds[i]);
        }
        bananaToken.transfer(msg.sender, rewards);
        emit RewardsClaimed(msg.sender, rewards, block.timestamp);
    }
   
    function setGenesisRate(uint256 _genesisRate) external onlyOwner {
        genesisRate = _genesisRate;
    }

    function setLegendRate(uint256 _legendRate) external onlyOwner {
        legendRate = _legendRate;
    }

    function setRareRate(uint256 _rareRate) external onlyOwner {
        rareRate = _rareRate;
    }

    function setCommonRate(uint256 _commonRate) external onlyOwner {
        commonRate = _commonRate;
    }

    function onERC721Received(
        address /*operatorI*/,
        address /*from*/,
        uint256 /*tokenId*/,
        bytes calldata /*data*/
    ) external pure override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function _stake(uint256 tokenId, uint256 t) internal {
        require(bananaNFT.ownerOf(tokenId) == msg.sender, "Not owner");
        require(!staked[msg.sender][tokenId], "");
        require(snapshot[msg.sender][tokenId] == 0, "");
        _setTokenRate(tokenId, t);
        
        bananaNFT.safeTransferFrom(msg.sender, address(this), tokenId);
        staked[msg.sender][tokenId] = true;
        snapshot[msg.sender][tokenId] = block.timestamp;
        ++totalStaked;
        emit Staked(msg.sender, tokenId, true);
    }

    function _unstake(uint256 tokenId) internal {
        require(bananaNFT.ownerOf(tokenId) == address(this), "Invalid tokenId");
        require(staked[msg.sender][tokenId], "");
        require(snapshot[msg.sender][tokenId] != 0, "");

        staked[msg.sender][tokenId] = false;
        snapshot[msg.sender][tokenId] = 0;
        --totalStaked;
        bananaNFT.safeTransferFrom(address(this), msg.sender, tokenId);
        
        emit Unstaked(msg.sender, tokenId, false);
    }

    function _updateRewards(uint256 tokenId) internal returns (uint256 rewards) {
        require(staked[msg.sender][tokenId], "");
        require(snapshot[msg.sender][tokenId] != 0, "");
        uint256 ElapsedTime = block.timestamp - snapshot[msg.sender][tokenId];
        snapshot[msg.sender][tokenId] = block.timestamp;
        rewards = (ElapsedTime) * tokenRate[tokenId] * 10**18 / 3600;
    }

    function _setTokenRate(uint256 tokenId, uint256 level) private {
        if (level == 0) {
            tokenRate[tokenId] = genesisRate;
        } else if (level == 1) {
            tokenRate[tokenId] = legendRate;
        } else if (level == 2) {
            tokenRate[tokenId] = rareRate;
        } else if (level == 3) {
            tokenRate[tokenId] = commonRate;
        } else {
            revert("Invalid level");
        }
    }
}