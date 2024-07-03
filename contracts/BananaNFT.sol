// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721Enumerable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract BananaNFT is ERC721Enumerable, Ownable {

    uint256 private _tokenIdCounter;

    IERC20 public token;
    uint256 public mintPrice = 0.01 ether;
    uint256 public mintInterval;
    uint256 public saleEndTime;
    bool public _isSaleActive;

    mapping(uint256 tokenId => string) public _tokenURIs;
    mapping(address => uint256) public lastMintTime;
    mapping(address => bool) public isOnline;

    event Minted(address indexed user, uint256 tokenId);

    constructor(
        uint256 _mintInterval,
        IERC20 _token
    ) ERC721("BananaNFT", "BNFT") Ownable(msg.sender) {
        mintInterval = _mintInterval;
        token = _token;
    }

    function startSale(uint256 duration) external onlyOwner {
        saleEndTime = block.timestamp + duration;
    }

    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        _requireOwned(tokenId);
        string memory _tokenURI = _tokenURIs[tokenId];
        return _tokenURI;
    }

    function payToMint(string memory uri) external payable returns (uint256) {
        require(_isSaleActive, "Sale is not active");
        require(block.timestamp < saleEndTime, "Sale ended");
        require(msg.value == mintPrice, "Incorrect ETH value");

        ++_tokenIdCounter;
        uint256 tokenId = _tokenIdCounter;
        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, uri);

        emit Minted(msg.sender, tokenId);

        return tokenId;
    }

    function judgeMint() external view returns (uint256 nextMintTime) {
        nextMintTime = lastMintTime[msg.sender] + mintInterval;
    }

    function mint(string memory uri) external returns (uint256) {
        require(
            block.timestamp >= lastMintTime[msg.sender] + mintInterval,
            "Not reach mint time"
        );

        ++_tokenIdCounter;
        uint256 tokenId = _tokenIdCounter;
        lastMintTime[msg.sender] = block.timestamp;
        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, uri);

        emit Minted(msg.sender, tokenId);

        return tokenId;
    }

    function _setTokenURI(
        uint256 tokenId,
        string memory _tokenURI
    ) internal virtual {
        _tokenURIs[tokenId] = _tokenURI;
    }

    function flipSaleActive() external onlyOwner {
        _isSaleActive = !_isSaleActive;
    }

    function setMintPrice(uint256 _mintPrice) external onlyOwner {
        mintPrice = _mintPrice;
    }

    function currentTokenId() public view returns (uint256) {
        return _tokenIdCounter;
    }

    function withdraw() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
}
