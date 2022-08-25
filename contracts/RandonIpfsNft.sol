//  SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "hardhat/console.sol";

// ERROR
error RandomIpfsNft__RangeOutOfBounds();

contract RandomIpfsNft is VRFConsumerBaseV2, ERC721URIStorage {
    // when we mint and  NFT, we will trigger a Chainlink VRF to get us a random number
    //  using that number, we will get a random NFT
    // PUG, Shiba Inu, St. Bernard
    // PUG super rare
    // shiba sort of rare
    // St. bernard common

    // users have to pay to min an NFT
    // the owner of the contract can withdraw the ETH

    // Type Declarations
    enum Breed {
        PUG,
        SHIBA_INU,
        ST_BERNARD
    }

    // Chainlink VRF Variables
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    uint64 private immutable i_subscriptionId;
    bytes32 private immutable i_gasLane;
    uint32 private immutable i_callbackGasLimit;
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;

    // VRF Helpers
    mapping(uint256 => address) public s_requestIdToSender;

    // NFT variables
    uint256 public s_tokenCounter; //should be private, public for learning purpose
    uint256 internal constant MAX_CHANCE_VALUE = 100;
    // string[] internal s_dogTokenUris = ["dfagrgsaf", "fsdf3435", "34131afsdg"];
    string[] internal s_dogTokenUris;

    constructor(
        address vrfCoordinatorV2,
        uint64 subscriptionId,
        bytes32 gasLane,
        // uint256 mintFee,
        uint32 callbackGasLimit,
        string[3] memory dogTokenUris
    ) VRFConsumerBaseV2(vrfCoordinatorV2) ERC721("Random IPFS NFT", "RIN") {
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinatorV2);
        i_subscriptionId = subscriptionId;
        i_gasLane = gasLane;
        i_callbackGasLimit = callbackGasLimit;
        s_dogTokenUris = dogTokenUris;
    }

    function requestNft() public returns (uint256 requestId) {
        requestId = i_vrfCoordinator.requestRandomWords(
            i_gasLane,
            i_subscriptionId,
            REQUEST_CONFIRMATIONS,
            i_callbackGasLimit,
            NUM_WORDS
        );
        s_requestIdToSender[requestId] = msg.sender;
    }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override {
        // _safeMint(msg.sender, s_tokenCounter);
        // msg.sender is actually the chainlink node not the actual owner
        // therefore, we need to set a mapping connect the owner and requestId
        address dogOwner = s_requestIdToSender[requestId]; // => msg.sender
        uint256 newTokenId = s_tokenCounter; // => s_tokenCounter
        uint256 moddedRng = randomWords[0] % MAX_CHANCE_VALUE;
        // 0 - 99
        // 7 -> PUG
        // 12 -> Shiba Inu
        // 88 -> St. Bernard
        // 45 -> St. Bernard

        Breed dogBreed = getBreedFromModdedRng(moddedRng);
        _safeMint(dogOwner, newTokenId);
        _setTokenURI(newTokenId, s_dogTokenUris[uint256(dogBreed)]);
    }

    function getBreedFromModdedRng(uint256 moddedRng) public pure returns (Breed) {
        uint256 cumulativeSum = 0;
        uint256[3] memory chanceArray = getChanceArray();
        // moddedRng = 8
        // i = 0
        // cumulativeSum = 0
        for (uint256 i = 0; i < chanceArray.length; i++) {
            if (moddedRng >= cumulativeSum && moddedRng < cumulativeSum + chanceArray[i]) {
                return Breed(i);
            }
            cumulativeSum += chanceArray[i];
        }
        revert RandomIpfsNft__RangeOutOfBounds();
    }

    function getChanceArray() public pure returns (uint256[3] memory) {
        return [10, 30, MAX_CHANCE_VALUE];
    }

    function tokenURI(uint256) public view override returns (string memory) {}
}
