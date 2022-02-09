const chai = require("chai");
const { expect } = chai
const { ethers } = require("hardhat");
const chaiAsPromised = require("chai-as-promised");

chai.use(chaiAsPromised);
describe("PodCastNFT", function () {
  let Contract, contract

  before(async () => {
    Contract = await ethers.getContractFactory("PodCastNFT");
  });

  it("send Eth to contract and contract is now rich", async () => {
    const [owner, user1] = await ethers.getSigners()
    contract = await Contract.deploy([user1.address], false)
    await contract.deployed()

    expect((await contract.getBalance()).toString()).to.equal('0')
    const tx = await owner.sendTransaction({
      to: contract.address,
      value: ethers.utils.parseEther("20.0"),
    });
    await tx.wait()
    expect((await contract.getBalance()).toString()).to.equal(ethers.utils.parseEther("20.0"))
  });
})
