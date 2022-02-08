const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("PodCastNFT", function () {
  let podCastNFTFactory;
  let podcastNFT;
  let admin1;
  let addr1;
  let addr2;
  let addrs;

  beforeEach(async function () {
    podcastNFTFactory = await ethers.getContractFactory("PodCastNFT");
    [owner, addr1, addr2, ...addrs] = await ethers.getSigners();
    podcastNFT = await podcastNFTFactory.deploy();
  });

  // adminはmintできる
  it("can mint for admin", async function () {
    const mintTx = await podcastNFT.mintAndTransfer(addr1.address);
    await mintTx.wait();
    expect(await podcastNFT.ownerOf(1)).to.be.equal(addr1.address);
  });

  // admin以外はmintできない
  // it("can not mint except for admin", async function () {
  //   await expect(
  //     podcastNFT.connect(addr1).mintAndTransfer(addr2.address)
  //   ).to.be.revertedWith("");
  // });
});
