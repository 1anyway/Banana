// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721Enumerable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract BananaNFT is ERC721Enumerable, ReentrancyGuard, Ownable {
    uint256 public mintPrice = 0.03 ether;
    uint256 public mintInterval;
    uint256 public endWhitelistMintTime;
    bool public _isSaleActive;
    uint256 private _tokenIdCounter;
    address private marketingWallet;

    mapping(uint256 tokenId => string) public _tokenURIs;
    mapping(address => bool) public whitelist;
    mapping(address => uint256) public lastMintTime;

    event Minted(address indexed user, uint256 tokenId);

    constructor(
        uint256 _mintInterval,
        uint256 whitelistMintTime,
        address _marketingWallet
    ) ERC721("BananaNFT", "BNFT") Ownable(msg.sender) {
        mintInterval = _mintInterval;
        endWhitelistMintTime = block.timestamp + whitelistMintTime;
        marketingWallet = _marketingWallet;
    }

    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        _requireOwned(tokenId);
        string memory _tokenURI = _tokenURIs[tokenId];
        return _tokenURI;
    }

    function payToMint(string memory uri) external payable nonReentrant {
        require(_isSaleActive, "Sale is not active");
        require(msg.value == mintPrice, "Incorrect ETH value");

        ++_tokenIdCounter;
        uint256 tokenId = _tokenIdCounter;
        (bool success, ) = payable(marketingWallet).call{value: msg.value}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, uri);

        emit Minted(msg.sender, tokenId);
    }

    function mint(string memory uri) external nonReentrant {
        require(
            block.timestamp >= lastMintTime[msg.sender] + mintInterval,
            "Not reach mint time"
        );
        if (block.timestamp < endWhitelistMintTime) {
            require(whitelist[msg.sender], "Only whitelist user can mint");
        }
        ++_tokenIdCounter;
        uint256 tokenId = _tokenIdCounter;
        lastMintTime[msg.sender] = block.timestamp;
        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, uri);

        emit Minted(msg.sender, tokenId);
    }

    function addToWhitelist(address user) external onlyOwner {
        whitelist[user] = true;
    }

    function setMintInterval(uint256 _mintInterval) external onlyOwner {
        mintInterval = _mintInterval;
    }

    function flipSaleActive() external onlyOwner {
        _isSaleActive = !_isSaleActive;
    }

    function setMintPrice(uint256 _mintPrice) external onlyOwner {
        mintPrice = _mintPrice;
    }

    function withdraw() external onlyOwner {
        payable(marketingWallet).transfer(address(this).balance);
    }

    function currentTokenId() public view returns (uint256) {
        return _tokenIdCounter;
    }

    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal {
        _tokenURIs[tokenId] = _tokenURI;
    }
}
