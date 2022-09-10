const { developmentChains } = require("../../helper-hardhat-config")
const { network, ethers, deployments } = require("hardhat")
const { assert, expect } = require("chai")

!developmentChains.includes(network.name)
    ? describe.skip
    : describe("Dynamic SVG NFT Unit Tests", function () {
          let dynamicSvgNft, deployer, mockV3Aggregator

          beforeEach(async () => {
              accounts = await ethers.getSigners()
              deployer = accounts[0]
              await deployments.fixture(["mocks", "dynamicsvg"])
              dynamicSvgNft = await ethers.getContract("DynamicSvgNft")
              mockV3Aggregator = await ethers.getContract("MockV3Aggregator")
          })

          describe("constructor", () => {
              it("sets starting values correctly", async function () {
                  const lowSVG = await dynamicSvgNft.getLowSVG()
                  const highSVG = await dynamicSvgNft.getHighSVG()
                  const priceFeed = await dynamicSvgNft.getPriceFeed()
                  assert.equal(lowSVG, lowSVGImageuri)
                  assert.equal(highSVG, highSVGImageuri)
                  assert.equal(priceFeed, mockV3Aggregator.address)
              })
          })

          describe("mintNft", () => {
              it("emits an event and creates the NFT", async () => {
                  const highValue = ethers.utils.parseEther("1")
                  await expect(dynamicSvgNft.mintNft(highValue)).to.emit(
                      dynamicSvgNft,
                      "CreatedNFT"
                  )
                  const tokenCounter = await dynamicSvgNft.getTokenCounter()
                  assert.qual(tokenCounter.toString(), "1")
                  const tokenURI = await dynamicSvgNft.tokenURI(0)
                  assert.qual(tokenURI, highTokenUri)
              })
          })
      })
