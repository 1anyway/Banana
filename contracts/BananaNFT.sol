// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721Enumerable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

contract BananaNFT is  ERC721Enumerable, Ownable {
    using Strings for uint256;

    uint256 private _tokenIdCounter;

    IERC20 public token;
    uint256 public mintPrice = 0.01 ether;
    uint256 public mintInterval;
    uint256 public saleEndTime;

    bool public _isSaleActive = false;
    // 初始化盲盒，等到一定时机可以随机开箱，变成true
    bool public _revealed = false;
    string baseURI;
    // 盲盒图片的meta,json地址，后文会提到
    string public notRevealedUri;

    mapping(uint256 tokenId => string) public _tokenURIs;
    mapping(address => uint256) public lastMintTime;
    mapping(uint256 => uint256) public tokenLevels;
    mapping(address => bool) public isOnline;

    event Minted(address indexed user, uint256 tokenId, uint256 level);

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

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        _requireOwned(tokenId);
        // if (_revealed == false) {
        //     return notRevealedUri;
        // }
        string memory _tokenURI = _tokenURIs[tokenId];
        return _tokenURI;
        // string memory base = _baseURI();

        // return bytes(base).length > 0 ? string(abi.encodePacked(base, tokenId.toString())) : "";
    }

    function mysteryBox() external payable {
        require(_isSaleActive, "Sale is not active");
        require(block.timestamp < saleEndTime, "Sale ended");
        require(msg.value == mintPrice, "Incorrect ETH value");

        ++_tokenIdCounter;
        uint256 tokenId = _tokenIdCounter;
        _safeMint(msg.sender, tokenId);

        uint256 level = _getRandomLevel();
        tokenLevels[tokenId] = level;

        emit Minted(msg.sender, tokenId, level);
    }

    function mint(string memory uri) external {
        require(
            block.timestamp >= lastMintTime[msg.sender] + mintInterval,
            "Isnt mint time"
        );
        require(isOnline[msg.sender], "You are not online");
        require(block.timestamp < saleEndTime, "Sale ended");

        ++_tokenIdCounter;
        uint256 tokenId = _tokenIdCounter;
        lastMintTime[msg.sender] = block.timestamp;
        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, uri);

        uint256 level = _getRandomLevel();
        tokenLevels[tokenId] = level;

        emit Minted(msg.sender, tokenId, level);
    }

    function updateOnlineMintTime(address user) external onlyOwner {
        lastMintTime[user] = block.timestamp;
        isOnline[user] = true;
    }

    function updateOutlineMintTime(address user) external onlyOwner{
        lastMintTime[user] = block.timestamp;
        isOnline[user] = false;
    }

    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        _tokenURIs[tokenId] = _tokenURI;
    }

    // function _baseURI() internal view virtual override returns (string memory) {
    //     return baseURI;
    // }
   
    function flipSaleActive() external onlyOwner {
        _isSaleActive = !_isSaleActive;
    }
   
    function flipReveal() external onlyOwner {
        _revealed = !_revealed;
    }
   
    function setMintPrice(uint256 _mintPrice) external onlyOwner {
        mintPrice = _mintPrice;
    }
   
    function setNotRevealedURI(string memory _notRevealedURI) external onlyOwner {
        notRevealedUri = _notRevealedURI;
    }
   
    // function setBaseURI(string memory _newBaseURI) external onlyOwner {
    //     baseURI = _newBaseURI;
    // }

    function currentTokenId() public view returns (uint256) {
        return _tokenIdCounter;
    }

    function _getRandomLevel() private view returns (uint256) {
        uint256 rand = uint256(
            keccak256(
                abi.encodePacked(
                    block.timestamp,
                    msg.sender,
                    _tokenIdCounter
                )
            )
        );
        if (rand % 100 < 5) {
            // 5% chance for high level
            return 3;
        } else if (rand % 100 < 20) {
            // 15% chance for mid level
            return 2;
        } else {
            // 80% chance for low level
            return 1;
        }
    }

    function withdraw() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
}
