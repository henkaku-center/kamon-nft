const hre = require('hardhat')

const main = async () => {
  const [owner] = await hre.ethers.getSigners()
  const MockERC20 = await hre.ethers.getContractFactory('MockERC20')
  const podcastNFTContract = await hre.ethers.getContractFactory('PodCastNFT')
  const erc20 = await MockERC20.deploy()
  await erc20.deployed()
  console.log('erc20: ', erc20.address)
  console.log('balance', await erc20.balanceOf(owner.address))

  const contract = await podcastNFTContract.deploy(erc20.address, owner.address)
  await contract.deployed()
  console.log('deployed to:', contract.address)

  const erc20WithSigner = erc20.connect(owner)
  const approveTx = await erc20WithSigner.approve(
    contract.address,
    '1000000000000000000000'
  )
  await approveTx.wait()
  console.log('Approve:', approveTx)

  const tx = await contract.mintWithHenkaku(
    'https://example.com/podcast.png',
    '1000000000000000000000'
  )
  tx.wait()
  console.log('After:', tx)
  console.log('balance', await erc20.balanceOf(owner.address))
  console.log('balance', await erc20.balanceOf(contract.address))
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })
