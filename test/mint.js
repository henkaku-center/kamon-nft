const chai = require("chai");
const { expect } = chai;
const { ethers } = require("hardhat");
const chaiAsPromised = require("chai-as-promised");

chai.use(chaiAsPromised);
describe("PodCastNFT", function () {
  let Contract, contract;
  let owner, alice, bob;

  beforeEach(async function () {
    Contract = await ethers.getContractFactory("PodCastNFT");
    [owner, alice, bob] = await ethers.getSigners();
    contract = await Contract.deploy();
    await contract.deployed();
  });

  describe("getRoles", () => {
    it("revert without nft", async () => {
      await expect(
        contract.getRoles(alice.address)
      ).to.be.revertedWith('wallet must have membership nft');
    })
    it("can retrieve roles", async () => {
      const mintTx = await contract.mint(
        "https://example.com/podcast.png",
        ['Podcast Contributor', 'MEMBER'],
        "10000",
        alice.address
      );
      await mintTx.wait();
      expect(await contract.ownerOf(1)).to.be.equal(alice.address);
      expect(await contract.getRoles(alice.address)).to.have.same.members(['Podcast Contributor', 'MEMBER'])
    })
  })

  describe("hasRoleOf", () => {
    it("revert without nft", async () => {
      await expect(
        contract.hasRoleOf(alice.address, "MEMBER")
      ).to.be.revertedWith('wallet must have membership nft');
    })
    it("returns true with member and false with admin role", async () => {
      const mintTx = await contract.mint(
        "https://example.com/podcast.png",
        ['Podcast Contributor', 'MEMBER'],
        "10000",
        alice.address
      );
      await mintTx.wait();
      expect(await contract.hasRoleOf(alice.address, 'MEMBER')).to.be.true
      expect(await contract.hasRoleOf(alice.address, 'ADMIN')).to.be.false
    })
  })

  describe("addRole", () => {
    it("revert without nft", async () => {
      await expect(
        contract.addRole(alice.address, "MEMBER")
      ).to.be.revertedWith('wallet must have membership nft');
    })
    it("add roles correctly", async () => {
      const mintTx = await contract.mint(
        "https://example.com/podcast.png",
        ['Podcast Contributor'],
        "10000",
        alice.address
      );
      await mintTx.wait();
      expect(await contract.hasRoleOf(alice.address, 'MEMBER')).to.be.false
      await contract.addRole(alice.address, "MEMBER")
      expect(await contract.hasRoleOf(alice.address, 'MEMBER')).to.be.true
    })
  })

  describe("setRoles", () => {
    it("revert without nft", async () => {
      await expect(
        contract.setRoles(alice.address, ["MEMBER", "ADMIN"])
      ).to.be.revertedWith('wallet must have membership nft');
    })
    it("add empty roles", async () => {
      const mintTx = await contract.mint(
        "https://example.com/podcast.png",
        ['Podcast Contributor'],
        "10000",
        alice.address
      );
      await mintTx.wait();
      expect(await contract.hasRoleOf(alice.address, 'MEMBER')).to.be.false
      await contract.setRoles(alice.address, [])
      expect(await contract.getRoles(alice.address)).to.have.same.members([])
    })

    it("add roles correctly", async () => {
      const mintTx = await contract.mint(
        "https://example.com/podcast.png",
        ['Podcast Contributor'],
        "10000",
        alice.address
      );
      await mintTx.wait();
      expect(await contract.hasRoleOf(alice.address, 'MEMBER')).to.be.false
      await contract.setRoles(alice.address, ["MEMBER", "ADMIN"])
      expect(await contract.getRoles(alice.address)).to.have.same.members(["MEMBER", "ADMIN"])
    })
  })

  it("can mint for admin", async function () {
    const mintTx = await contract.mint(
      "https://example.com/podcast.png",
        ['Podcast Contributor'],
      "10000",
      alice.address
    );
    await mintTx.wait();
    expect(await contract.ownerOf(1)).to.be.equal(alice.address);
  });

  it("cannot mint twice for the same user(owner)", async function () {
    const mintTx = await contract.mint(
      "https://example.com/podcast.png",
      ['Podcast Contributor'],
      "10000",
      alice.address
    );
    await mintTx.wait();

    await expect(
        contract.mint(
          "https://example.com/podcast.png",
          ['Podcast Contributor'],
          "10000",
          alice.address
        )
    ).eventually.to.rejectedWith(Error)
  });
});
