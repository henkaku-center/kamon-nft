require('dotenv').config()

const hre = require('hardhat')

const main = async () => {
  const HenkakuToken = await hre.ethers.getContractFactory('MockERC20')
  const henkakuToken = await HenkakuToken.deploy()
  await henkakuToken.deployed()
  console.log('token deployed to:', henkakuToken.address)
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })
