const hre = require("hardhat");

const main = async () => {
  const [owner, randomUser] = await hre.ethers.getSigners();
  const podcastNFTContract = await hre.ethers.getContractFactory("PodCastNFT");
  const contract = await podcastNFTContract.deploy([owner.address], false);

  await contract.deployed();
  console.log("deployed to:", contract.address);

  const tx = await contract.mintAndTransfer(randomUser.address);
  await tx.wait();

  const user = await contract.ownerOf(1);
  console.log("Owner:", user);
  const uri = await contract.tokenURI(1);
  console.log("URI: ", uri);
};

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
