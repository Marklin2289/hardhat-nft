//  SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "hardhat/console.sol";

contract RandomIpfsNft {
    // when we mint and  NFT, we will trigger a Chainlink VRF to get us a random number
    //  using that number, we will get a random NFT
    // PUG, Shiba Inu, St. Bernard
    // PUG super rare
    // shiba sort of rare
    // St. bernard common

    // users have to pay to min an NFT
    // the owner of the contract can withdraw the ETH
    function requestNft() public {}

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal {}

    function tokenURI(uint256) public {}
}
