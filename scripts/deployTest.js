require('dotenv').config()

const hre = require('hardhat')

const main = async () => {
  const HenkakuToken = await hre.ethers.getContractFactory('MockERC20')
  const henkakuToken = await HenkakuToken.deploy()
  await henkakuToken.deployed()
  const podcastNFTContract = await hre.ethers.getContractFactory('PodCastNFT')
  const contract = await podcastNFTContract.deploy(
    henkakuToken.address,
    process.env.FUND_ADDRESS
  )

  await contract.deployed()
  console.log('token deployed to:', henkakuToken.address)
  console.log('deployed to:', contract.address)
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })
