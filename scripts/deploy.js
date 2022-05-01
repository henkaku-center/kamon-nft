require('dotenv').config()

const hre = require('hardhat')

const main = async () => {
  const podcastNFTContract = await hre.ethers.getContractFactory('PodCastNFT')
  const contract = await podcastNFTContract.deploy(
    process.env.TOKEN_ADDRESS,
    process.env.FUND_ADDRESS
  )

  await contract.deployed()
  console.log('deployed to:', contract.address)
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })
