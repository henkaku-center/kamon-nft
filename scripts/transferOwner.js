require('dotenv').config()

const hre = require('hardhat')

const main = async () => {
  const kamonNFTContract = await hre.ethers.getContractFactory('KamonNFT')
  const contract = await kamonNFTContract.attach('0x539BCf896f02459dBcB3a2F1D823d2E65DB7211C')

  let tx = await contract.transferOwnership('0xF3fb03B582bd19CfA6728FDED7e130aad396d99E')
  tx.wait()
  console.log('deployed to:', contract.address)

}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })
