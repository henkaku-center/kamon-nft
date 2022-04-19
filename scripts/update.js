const hre = require('hardhat')

const main = async () => {
  const [owner] = await hre.ethers.getSigners()
  const podcastNFTContract = await hre.ethers.getContractFactory('PodCastNFT')
  const contract = await podcastNFTContract.deploy([owner.address], false)

  await contract.deployed()
  console.log('deployed to:', contract.address)

  const tx1 = await contract.mint(
    'https://dl.dropboxusercontent.com/s/ifuvt9h1spilofh/QmW2AHtZWdeE73ae73PkexAHDboisuZiyB8hGJtyXn5bCn.png',
    'Henkaku Master',
    '',
    '10000',
    owner.address
  )
  await tx1.wait()

  const user1 = await contract.ownerOf(1)
  console.log('Owner:', user1)
  const uri1 = await contract.tokenURI(1)
  console.log('URI: ', uri1)

  const tx2 = await contract.updateNFT(
    1,
    'https://dl.dropboxusercontent.com/s/svwstwur6kqdaib/DmW2AHtZWdeE73ae73PkexAHDboisuZiyB8hGJtyXn5bCn.png',
    'Henkaku King',
    'member',
    '100000000'
  )
  await tx2.wait()

  const user2 = await contract.ownerOf(1)
  console.log('Owner:', user2)
  const uri2 = await contract.tokenURI(1)
  console.log('URI: ', uri2)
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })
