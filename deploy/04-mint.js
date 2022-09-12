const { network, ethers } = require("hardhat")

module.exports = async ({ getNamedAccounts }) => {
    const { deployer } = await getNamedAccounts()
    const chainId = network.config.chainId

    // Basic NFT mintNft
    const basicNft = await ethers.getContract("BasicNft", deployer)
    const basicMinTx = await basicNft.mintNft()
    await basicMinTx.wait(1)
    console.log("---------------------------------------------------------------------")
    console.log(`Basic NFT index 0 tokenURI is : ${await basicNft.tokenURI(0)}`)

    // Dynamic SVG NFT mint
    const highValue = ethers.utils.parseEther("4000")
    const dynamicSvgNft = await ethers.getContract("DynamicSvgNft", deployer)
    const dynamicSvgNftMinTx = await dynamicSvgNft.mintNft(highValue)
    await dynamicSvgNftMinTx.wait(1)
    console.log("----------------------------High Value-------------------------------------")
    console.log(`Dynamic SVG NFT index 0 tokenURI is ${await dynamicSvgNft.tokenURI(0)}`)

    // random IPFS NFT mint
    const randomIpfsNft = await ethers.getContract("RandomIpfsNft", deployer)
    const mintFee = await randomIpfsNft.getMintFee()
    const randomIpfsNftMinTx = await randomIpfsNft.requestNft({ value: mintFee.toString() })
    const randomIpfsNftMintTxReceipt = await randomIpfsNftMinTx.wait(1)
    //  Need to listen for response
    await new Promise(async (resolve, reject) => {
        setTimeout(() => reject("Timeout: 'NFTMinted' event did not fire"), 300000) // 5 minutes timeout
        // setup listener for our event
        randomIpfsNft.once("NftMinted", async () => {
            resolve()
        })
        if (chainId == 31337) {
            const requestId = randomIpfsNftMintTxReceipt.events[1].args.requestId.toString()
            const vrfCoordinatorV2Mock = await ethers.getContract("VRFCoordinatorV2Mock", deployer)
            await vrfCoordinatorV2Mock.fulfillRandomWords(requestId, randomIpfsNft.address)
        }
    })
    console.log("---------------------------------------------------------------------")
    console.log(`Random IPFS NFT index 0 tokenURI is : ${await randomIpfsNft.tokenURI(0)}`)
}

module.exports.tags = ["all", "mint"]
