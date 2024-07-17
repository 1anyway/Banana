// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

import "forge-std/Script.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

interface IBananaNFT {
    function addToWhitelist(address user) external;
}

contract AddToWhitelist is Script {
    using stdJson for string;

    function run() external {
        // fs_permissions = [{ access = "read", path = "script/whitelist.json" }]
        string memory json = vm.readFile("script/whitelist.json");
        // string memory json = '{"addresses": ["0xb162A4E92229555a27A581c1B7d4D887C2b326b6","0x7748DDCdCA8dbf6A8A7Af5868E91d13d457b5F47","0x9B0DF08D93D80EF213Da6D91B14757Aa56bb7b14","0x040561980F9966cbFA5EE7d5716B8B0a804733CB","0x088255712453637bd2bbba4295653f4041ae99ad","0x06d2540ab208d43fef6b06c54d1bcadd0c7f933c","0x8F77c8A7d9c65bb61F2B4AAfE2E7a89f87e1cA14","0xef245bF9035fD7A595eACaEa10EBB1858e08F0Dc","0x91B2F5aDC9449F762D81287F455EF13b9dDA40D4"]}';
//    string memory json = '{"addresses":["0x123...","0x456...","0x789..."]}';
        // address[] memory addresses = abi.decode(vm.parseJson(json).array("addresses"), (address[]));
        bytes memory jsonBytes = vm.parseJson(json);
        // 解码 JSON 数据为 address[] 类型
        address[] memory addresses = abi.decode(jsonBytes, (address[]));
        address nftContractAddress = vm.envAddress("NFT_CONTRACT_ADDRESS");
        IBananaNFT nftContract = IBananaNFT(nftContractAddress);

        vm.startBroadcast();

        for (uint256 i = 0; i < addresses.length; i++) {
            nftContract.addToWhitelist(addresses[i]);
            console.log("Added to whitelist:", addresses[i]);
        }

        vm.stopBroadcast();
    }
}
