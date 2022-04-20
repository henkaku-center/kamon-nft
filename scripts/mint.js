const hre = require("hardhat");

const main = async () => {
  const [owner] = await hre.ethers.getSigners();
  const MockERC20 = await hre.ethers.getContractFactory("MockERC20");
  const podcastNFTContract = await hre.ethers.getContractFactory("PodCastNFT");
  const erc20 = await MockERC20.deploy();
  await erc20.deployed()
  console.log('erc20: ', erc20.address)
  console.log('balance', await erc20.balanceOf(owner.address))

  const contract = await podcastNFTContract.deploy(erc20.address);
  await contract.deployed();
  console.log("deployed to:", contract.address);

  const tx = await contract.buyWithHenkaku(100, contract.address)
  tx.wait()
  console.log("After:", tx);
  console.log('balance', await erc20.balanceOf(owner.address))
  console.log('balance', await erc20.balanceOf(contract.address))
};

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
