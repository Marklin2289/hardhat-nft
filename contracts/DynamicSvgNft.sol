// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// import ERC721 
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "base64-sol/base64.sol";
import "hardhat/console.sol";

contract DynamicSvgNft is ERC721, Ownable {
    /* 
    mint
    store our SVG information somewhere
    Some logic to say "Show X Image" or "Show Y Image"
    */
    uint256 private s_tokenCounter;
    string private s_lowImageURI;
    string private s_highImageURI;
    string private constant base64EncodedSvgPrefix = "data:image/svg+xml;base64,";

    mapping(uint256 => int256) private s_tokenIdToHighValues;
    AggregatorV3Interface internal immutable i_priceFeed;
    // event CreateNFT(uint256 indexed tokenId, int256 highValue);

    constructor(address priceFeedAddress, string memory lowSvg, string memory highSvg)ERC721("Dynamic SVG NFT", "DSN"){
        s_tokenCounter = 0; // initialize value
        i_priceFeed = AggregatorV3Interface(priceFeedAddress);
        //  setLowSVG(lowSvg);
        //  setHighSVG(highSvg);
        s_lowImageURI = svgToImageURI(lowSvg);
        s_highImageURI = svgToImageURI(highSvg);

    }

    function svgToImageURI(string memory svg) public pure returns (string memory) {
        string memory baseURL = "data:image/svg+xml;base64,";
        string memory svgBase64Encoded = Base64.encode(bytes(string(abi.encodePacked(svg))));
        return string(abi.encodePacked(baseURL, svgBase64Encoded));
    }

    function mintNft()public {
        _safeMint(msg.sender, s_tokenCounter);
        s_tokenCounter += 1;
    }
}