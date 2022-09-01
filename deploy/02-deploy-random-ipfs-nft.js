const { network, ethers } = require("hardhat")
const { developmentChains, networkConfig } = require("../helper-hardhat-config")
const { storageImages } = require("../utils/uploadToPinata")

const imagesLocation = "./images/randomNft"

module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()
    const chainId = network.config.chainId
    let tokenUris
    let vrfCoordinatorV2Address, subscriptionId
    // get the IPFS hashes of our images

    // 1. With our own IPFS nodes. https://docs.ipfs.io/
    // 2. Pinata https://www.pinata.cloud (we are going to use this)
    // 3. NFT.storage https://nft.storage
    if (process.env.UPLOAD_TO_PINATA == "true") {
        tokenUris = await handleTokenUris()
    }

    if (chainId == 31337) {
        // create VRFV2 Subscription
        const vrfCoordinatorV2Mock = await ethers.getContract("VRFCoordinatorV2Mock")
        vrfCoordinatorV2Address = vrfCoordinatorV2Mock.address
        const transactionResponse = await vrfCoordinatorV2Mock.createSubscription()
        const transactionReceipt = await transactionResponse.wait()
        subscriptionId = transactionReceipt.events[0].args.subId
        // Fund the subscription
        // Our mock makes it so we don't actually have to worry about sending fund
    } else {
        vrfCoordinatorV2Address = networkConfig[chainId].vrfCoordinatorV2
        subscriptionId = networkConfig[chainId].subscriptionId
    }
    log("---------------------------------------")
    await storageImages(imagesLocation)
    // const args = [
    //     vrfCoordinatorV2Address,
    //     subscriptionId,
    //     networkConfig[chainId].gasLane,
    //     networkConfig[chainId].callbackGasLimit,
    //     // tokenURIs
    //     networkConfig[chainId].mintFee,
    // ]
}

// create function handleTokenUris
async function handleTokenUris() {
    tokenUris = []

    return tokenUris
}

module.exports.tags = ["all", "randomipfs", "main"]
