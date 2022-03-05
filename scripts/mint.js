const hre = require("hardhat");

const main = async () => {
  const [owner] = await hre.ethers.getSigners();
  const podcastNFTContract = await hre.ethers.getContractFactory("PodCastNFT");
  const contract = await podcastNFTContract.deploy([owner.address], false);

  await contract.deployed();
  console.log("deployed to:", contract.address);

  const tx = await contract.mint(
    "https://dl.dropboxusercontent.com/s/ifuvt9h1spilofh/QmW2AHtZWdeE73ae73PkexAHDboisuZiyB8hGJtyXn5bCn.png",
    "Henkaku Master",
    "Henkaku Community Member",
    "10000",
    owner.address
  );
  await tx.wait();

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
