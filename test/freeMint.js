const chai = require("chai");
const { expect } = chai;
const { ethers } = require("hardhat");
const chaiAsPromised = require("chai-as-promised");

chai.use(chaiAsPromised);
describe("PodCastNFT free mint", function () {
  let Contract, contract;

  beforeEach(async function () {
    Contract = await ethers.getContractFactory("PodCastNFT");
  });

  it("can mint for admin", async function () {
    const [owner, user1] = await ethers.getSigners();
    contract = await Contract.deploy([owner.address], false);
    await contract.deployed();

    const mintTx = await contract.mintAndTransfer(user1.address);
    await mintTx.wait();
    expect(await contract.ownerOf(1)).to.be.equal(user1.address);
  });
});
