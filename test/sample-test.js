const { expect } = require("chai");
const { ethers } = require("hardhat");

async function deploy(name, ...params) {
  const Contract = await ethers.getContractFactory(name);
  return await Contract.deploy(...params).then((f) => f.deployed());
}

describe("PodCastNFT", function () {
  beforeEach(async function () {
    this.forwarder = await deploy("MinimalForwarder");
    this.podcastNFT = await deploy("PodCastNFT", this.forwarder.address);
    this.accounts = await ethers.getSigners();
  });

  // adminはmintできる
  it("can mint for admin", async function () {
    const sender = this.accounts[1];
    const podcastNFT = this.podcastNFT.connect(sender);

    const receipt = await podcastNFT.mintAndTransfer(sender.address).then((tx) => tx.wait());
    expect(await podcastNFT.ownerOf(1)).to.be.equal(sender.address);
  });
});
