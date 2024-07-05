// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {BananaNFT} from "./BananaNFT.sol";

contract BananaMarketplace is IERC721Receiver, Ownable {
    IERC20 public token;
    BananaNFT public bananaNFT;
    bool public isFloorSet;
    uint256 public floorPrice;
    uint256 public burnRate = 5; // 5%
    
    struct Listing {
        address seller;
        uint256 price;
        bool listed;
    }
    
    mapping(uint256 => Listing) public listings;

    event Listed(uint256 indexed tokenId, address seller, uint256 price);
    event Unlisted(uint256 indexed tokenId, address seller);
    event Purchased(uint256 indexed tokenId, address buyer, uint256 price);

    constructor(IERC20 _token, BananaNFT _nft) Ownable(msg.sender) {
        token = _token;
        bananaNFT = _nft;
    }

    function listNFT(uint256 tokenId, uint256 price) external {
        if (isFloorSet) {
            require(price >=  floorPrice, "Floor price must greater than 100 token");
        }
        require(!listings[tokenId].listed, "Already listed");
        require(bananaNFT.ownerOf(tokenId) == msg.sender, "Not owner");

        bananaNFT.safeTransferFrom(msg.sender, address(this), tokenId);
        listings[tokenId] = Listing({seller: msg.sender, price: price, listed: true});

        emit Listed(tokenId, msg.sender, price);
    }

    function unlistNFT(uint256 tokenId) external {
         require(listings[tokenId].listed, "token not list");
         require(bananaNFT.ownerOf(tokenId) == msg.sender, "Not owner");

         bananaNFT.safeTransferFrom(address(this), msg.sender, tokenId);
        
         delete listings[tokenId];

         emit Unlisted(tokenId, msg.sender);
    }

    function buyNFT(uint256 tokenId) external {
        Listing memory listing = listings[tokenId];
        require(listing.listed, "Not listed");

        uint256 burnAmount = (listing.price * burnRate) / 100;
        uint256 sellerAmount = listing.price - burnAmount;

        token.transferFrom(msg.sender, address(this), burnAmount);
        token.transferFrom(msg.sender, listing.seller, sellerAmount);
        bananaNFT.safeTransferFrom(address(this), msg.sender, tokenId);

        delete listings[tokenId];
        emit Purchased(tokenId, msg.sender, listing.price);
    }

    function setFloorPrice(uint256 _floorPrice) external onlyOwner {
        floorPrice = _floorPrice;
    } 

    function onERC721Received(
        address /*operatorI*/,
        address /*from*/,
        uint256 /*tokenId*/,
        bytes calldata /*data*/
    ) external pure override returns (bytes4) {
        return this.onERC721Received.selector;
    }
    
    function setBurnRate(uint256 _burnRate) external onlyOwner {
        require(_burnRate < 20, "Invalid burnRate");
        burnRate = _burnRate;
    }

    function toggleIsFloorPrice() external onlyOwner {
        isFloorSet = !isFloorSet;
    }

    function withdrawBurnedTokens() external onlyOwner {
        uint256 balance = token.balanceOf(address(this));
        token.transfer(owner(), balance);
    }
}