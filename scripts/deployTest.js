require('dotenv').config()

const hre = require('hardhat')

const main = async () => {
  const HenkakuToken = await hre.ethers.getContractFactory('MockERC20')
  const henkakuToken = await HenkakuToken.deploy()
  await henkakuToken.deployed()
  const kamonNFTContract = await hre.ethers.getContractFactory('KamonNFT')
  const contract = await kamonNFTContract.deploy(
    '0x6FDDbe89B90795Eb0652F80fc3dBC2c61e753b1C', //henkakuToken.address,
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
