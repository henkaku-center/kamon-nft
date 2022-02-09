const hre = require("hardhat");

const main = async () => {
  const [owner, randomUser] = await hre.ethers.getSigners()
  const podcastNFTContract = await hre.ethers.getContractFactory("PodCastNFT");
  const contract = await podcastNFTContract.deploy([owner.address], false);

  await contract.deployed();
  console.log("deployed to:", contract.address);

  console.log("balance of contract: ", await contract.getBalance());
  const tx = await owner.sendTransaction({
    to: contract.address,
    value: ethers.utils.parseEther("1.0"), // Sends exactly 1.0 ether
  });
  await tx.wait()
  console.log("balance of contract: ", await contract.getBalance());
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
