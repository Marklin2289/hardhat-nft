const { network, ethers } = require("hardhat")

module.exports = async ({ getNamedAccounts }) => {
    const { deployer } = await getNamedAccounts()
    const chainId = network.config.chainId

    // Basic NFT mintNft
    const basicNft = await ethers.getContract("BasicNft", deployer)
    const basicMinTx = await basicNft.mintNft()
    await basicMinTx.wait(1)
    console.log(`Basic NFT index 0 tokenURI is : ${await basicNft.tokenURI(0)}`)

    // Dynamic SVG NFT mint
    const highValue = ethers.utils.parseEther("4000")
    const dynamicSvgNft = await ethers.getContract("DynamicSvgNft", deployer)
    const dynamicSvgNftMinTx = await dynamicSvgNft.mintNft(highValue)
    await dynamicSvgNftMinTx.wait(1)
    console.log(`Dynamic SVG NFT index 0 tokenURI is ${dynamicSvgNft.tokenURI(0)}`)
}
