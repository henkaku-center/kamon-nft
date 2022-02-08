const chai = require("chai");
const { expect } = chai
const { ethers } = require("hardhat");
const chaiAsPromised = require("chai-as-promised");

chai.use(chaiAsPromised);
describe("consensusAdminable", function () {
  let Contract, contract
  const ADMIN_ROLE = ethers.utils.keccak256(ethers.utils.toUtf8Bytes("ADMIN_ROLE"))
  before(async () => {
    Contract = await ethers.getContractFactory("ConsensusAdminable");
    const [admin1, admin2, user1, user2] = await ethers.getSigners()
  });

  it("given admin user only should have admin role", async () => {
    const [admin1, admin2, user1, user2] = await ethers.getSigners()
    contract = await Contract.deploy([admin1.address, admin2.address], false)
    await contract.deployed()
    expect(await contract.connect(admin1).hasRole(ADMIN_ROLE, admin1.address)).to.equal(true)
    expect(await contract.connect(admin1).hasRole(ADMIN_ROLE, admin2.address)).to.equal(true)

    expect(await contract.connect(user1).hasRole(ADMIN_ROLE, user1.address)).to.equal(false)
    expect(await contract.connect(user2).hasRole(ADMIN_ROLE, user2.address)).to.equal(false)
  });

  it("Add admin needs to have 30% of consensus", async () => {
    const [admin1, admin2, admin3, admin4, admin5, admin6, user1, user2] = await ethers.getSigners()
    contract = await Contract.deploy([admin1.address, admin2.address, admin3.address, admin4.address, admin5.address, admin6.address], false)
    await contract.deployed()

    expect(await contract.hasRole(ADMIN_ROLE, user1.address)).to.equal(false)

    await contract.connect(admin1).acceptAsAdmin(user1.address)
    expect(await contract.hasRole(ADMIN_ROLE, user1.address)).to.equal(false)

    await contract.connect(admin2).acceptAsAdmin(user1.address)
    expect(await contract.hasRole(ADMIN_ROLE, user1.address)).to.equal(true)
  })


  it("you cannot vote more than once", async () => {
    const [admin1, admin2, admin3, admin4, admin5, admin6, user1, user2] = await ethers.getSigners()
    contract = await Contract.deploy([admin1.address, admin2.address, admin3.address, admin4.address, admin5.address, admin6.address], false)
    await contract.deployed()
    await contract.connect(admin1).acceptAsAdmin(user1.address)
    await expect(contract.connect(admin1).acceptAsAdmin(user1.address)).eventually.to.rejectedWith(Error)

    await contract.connect(admin1).acceptWithdraw(admin2.address)
    await expect(contract.connect(admin1).acceptWithdraw(admin2.address)).eventually.to.rejectedWith(Error)
  })

  it("Withdraw admin needs to have 30% of consensus", async () => {
    const [admin1, admin2, admin3, admin4, admin5, admin6, user1, user2] = await ethers.getSigners()
    contract = await Contract.deploy([admin1.address, admin2.address, admin3.address, admin4.address, admin5.address, admin6.address], false)
    await contract.deployed()

    expect(await contract.hasRole(ADMIN_ROLE, admin2.address)).to.equal(true)

    await contract.connect(admin1).acceptWithdraw(admin2.address)
    expect(await contract.hasRole(ADMIN_ROLE, admin2.address)).to.equal(true)

    await contract.connect(admin3).acceptWithdraw(admin2.address)
    expect(await contract.hasRole(ADMIN_ROLE, admin2.address)).to.equal(false)
  })

});
