const hre = require("hardhat");

const main = async () => {
  const [admin1, admin2, user1, user2] = await hre.ethers.getSigners()
  const podcastNFTContract = await hre.ethers.getContractFactory("PodCastNFT");
  const contract = await podcastNFTContract.deploy([admin1.address, admin2.address], false);

  await contract.deployed();

  let txn;
  txn = await contract.connect(admin1).updateNFT(1)
  await txn.wait()

  txn = await contract.connect(admin2).updateNFT(1)
  await txn.wait()
  // use admin
  //const adminRole = hre.ethers.utils.keccak256(hre.ethers.utils.toUtf8Bytes("ADMIN_ROLE"))
  //txn = await contract.connect(admin1).grantRole(adminRole, user1.address)
  //await txn.wait()

  txn = await contract.connect(admin1).acceptAsAdmin(user1.address)
  await txn.wait()
  txn = await contract.connect(user1).updateNFT(1)
  await txn.wait()

  txn = await contract.connect(admin1).acceptWithdraw(user1.address)
  await txn.wait()

  txn = await contract.connect(user1).updateNFT(1)
  await txn.wait() // fail

  txn = await contract.connect(user2).updateNFT(1)
  await txn.wait() // fail
  console.log("deployed to:", contract.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
