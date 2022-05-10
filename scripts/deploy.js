require('dotenv').config()

const hre = require('hardhat')

const main = async () => {
  const kamonNFTContract = await hre.ethers.getContractFactory('KamonNFT')
  const contract = await kamonNFTContract.deploy(
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
