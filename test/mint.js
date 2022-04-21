const chai = require('chai')
const { expect } = chai
const { ethers } = require('hardhat')
const chaiAsPromised = require('chai-as-promised')

chai.use(chaiAsPromised)
describe('PodCastNFT', function () {
  let Contract, contract, HenkakuToken, henkakuToken
  let owner, alice, bob, fundAddress, price

  beforeEach(async function () {
    HenkakuToken = await ethers.getContractFactory('MockERC20')
    henkakuToken = await HenkakuToken.deploy()
    await henkakuToken.deployed()
    price = ethers.utils.parseUnits('1000', 18)

    Contract = await ethers.getContractFactory('PodCastNFT')
    ;[owner, alice, bob, fundAddress] = await ethers.getSigners()
    contract = await Contract.deploy(henkakuToken.address, fundAddress.address)
    await contract.deployed()
  })

  describe('getRoles', () => {
    it('return empty without nft', async () => {
      expect(await contract.getRoles(alice.address)).to.eql([])
    })
    it('can retrieve roles', async () => {
      const mintTx = await contract.mint(
        'https://example.com/podcast.png',
        ['Podcast Contributor', 'MEMBER'],
        '10000',
        alice.address
      )
      await mintTx.wait()
      expect(await contract.ownerOf(1)).to.be.equal(alice.address)
      expect(await contract.getRoles(alice.address)).to.have.same.members([
        'Podcast Contributor',
        'MEMBER',
      ])
    })
  })

  describe('hasRoleOf', () => {
    it('return false without nft', async () => {
      expect(await contract.hasRoleOf(alice.address, 'MEMBER')).to.be.false
    })
    it('returns true with member and false with admin role', async () => {
      const mintTx = await contract.mint(
        'https://example.com/podcast.png',
        ['Podcast Contributor', 'MEMBER'],
        '10000',
        alice.address
      )
      await mintTx.wait()
      expect(await contract.hasRoleOf(alice.address, 'MEMBER')).to.be.true
      expect(await contract.hasRoleOf(alice.address, 'ADMIN')).to.be.false
    })
  })

  describe('addRole', () => {
    it('revert without nft', async () => {
      await expect(
        contract.addRole(alice.address, 'MEMBER')
      ).to.be.revertedWith('wallet must have membership nft')
    })
    it('add roles correctly', async () => {
      const mintTx = await contract.mint(
        'https://example.com/podcast.png',
        ['Podcast Contributor'],
        '10000',
        alice.address
      )
      await mintTx.wait()
      expect(await contract.hasRoleOf(alice.address, 'MEMBER')).to.be.false
      await contract.addRole(alice.address, 'MEMBER')
      expect(await contract.hasRoleOf(alice.address, 'MEMBER')).to.be.true
    })
  })

  describe('setRoles', () => {
    it('revert without nft', async () => {
      await expect(
        contract.setRoles(alice.address, ['MEMBER', 'ADMIN'])
      ).to.be.revertedWith('wallet must have membership nft')
    })
    it('add empty roles', async () => {
      const mintTx = await contract.mint(
        'https://example.com/podcast.png',
        ['Podcast Contributor'],
        '10000',
        alice.address
      )
      await mintTx.wait()
      expect(await contract.hasRoleOf(alice.address, 'MEMBER')).to.be.false
      await contract.setRoles(alice.address, [])
      expect(await contract.getRoles(alice.address)).to.have.same.members([])
    })

    it('add roles correctly', async () => {
      const mintTx = await contract.mint(
        'https://example.com/podcast.png',
        ['Podcast Contributor'],
        '10000',
        alice.address
      )
      await mintTx.wait()
      expect(await contract.hasRoleOf(alice.address, 'MEMBER')).to.be.false
      await contract.setRoles(alice.address, ['MEMBER', 'ADMIN'])
      expect(await contract.getRoles(alice.address)).to.have.same.members([
        'MEMBER',
        'ADMIN',
      ])
    })
  })

  it('can mint for admin', async function () {
    const mintTx = await contract.mint(
      'https://example.com/podcast.png',
      ['Podcast Contributor'],
      '10000',
      alice.address
    )
    await mintTx.wait()
    expect(await contract.ownerOf(1)).to.be.equal(alice.address)
  })

  it('cannot mint twice for the same user(owner)', async function () {
    const mintTx = await contract.mint(
      'https://example.com/podcast.png',
      ['Podcast Contributor'],
      '10000',
      alice.address
    )
    await mintTx.wait()

    await expect(
      contract.mint(
        'https://example.com/podcast.png',
        ['Podcast Contributor'],
        '10000',
        alice.address
      )
    ).eventually.to.rejectedWith(Error)
  })

  describe('setPrice', () => {
    it('reverts with less amount', async () => {
      await expect(
        contract.setPrice(ethers.utils.parseUnits('1', 17))
      ).eventually.to.rejectedWith('price must be higher than 1e18 wei')
    })

    it('reverts when normal user try to change', async () => {
      await expect(
        contract.connect(alice).setPrice(ethers.utils.parseUnits('500', 18))
      ).eventually.to.rejectedWith(Error)
    })

    it('sets price correctly', async () => {
      expect(await contract.price()).to.eq(ethers.utils.parseUnits('1000', 18))
      await contract.setPrice(ethers.utils.parseUnits('500', 18))
      expect(await contract.price()).to.eq(ethers.utils.parseUnits('500', 18))
    })
  })

  describe('mintWithHenkaku', () => {
    it('revert without approval', async () => {
      await expect(
        contract.mintWithHenkaku(
          'https://example.com/podcast.png',
          'joi.eth',
          ethers.utils.parseUnits('1000', 18)
        )
      ).eventually.to.rejectedWith(Error)
    })

    it('revert if you have more than 1 membershipNFT', async () => {
      await henkakuToken.transfer(
        alice.address,
        ethers.utils.parseUnits('3000', 18)
      )
      const balance = await henkakuToken.balanceOf(alice.address)
      await henkakuToken.connect(alice).approve(contract.address, price)
      const tx = await contract
        .connect(alice)
        .mintWithHenkaku(
          'https://example.com/podcast.png',
          'joi.eth',
          ethers.utils.parseUnits('1000', 18)
        )
      await tx.wait()
      expect(await contract.balanceOf(alice.address)).to.eq(1)
      await expect(
        contract
          .connect(alice)
          .mintWithHenkaku(
            'https://example.com/podcast.png',
            'joi.eth',
            ethers.utils.parseUnits('1000', 18)
          )
      ).eventually.to.rejectedWith('User has already had a memebrship NFT')
    })

    it('revert if you try to buy with less price', async () => {
      await henkakuToken.transfer(
        alice.address,
        ethers.utils.parseUnits('1400', 18)
      )
      const balance = await henkakuToken.balanceOf(alice.address)
      await henkakuToken.connect(alice).approve(contract.address, price)
      await expect(
        contract
          .connect(alice)
          .mintWithHenkaku(
            'https://example.com/podcast.png',
            'joi.eth',
            ethers.utils.parseUnits('900', 18)
          )
      ).eventually.to.rejectedWith('Not Enough Henkaku')
    })

    it('mint With henkaku token', async () => {
      const balance = await henkakuToken.balanceOf(owner.address)
      await henkakuToken.approve(contract.address, price)
      expect(await henkakuToken.balanceOf(contract.address)).to.be.eq(0)
      const tx = await contract.mintWithHenkaku(
        'https://example.com/podcast.png',
        'joi.eth',
        ethers.utils.parseUnits('1000', 18)
      )
      await tx.wait()
      expect(await contract.balanceOf(owner.address)).to.eq(1)
      expect(await contract.hasRoleOf(owner.address, 'MEMBER')).to.be.true
      expect(await contract.hasRoleOf(owner.address, 'MINTER')).to.be.true
      expect(await henkakuToken.balanceOf(owner.address)).to.be.eq(
        balance.sub(price)
      )
      expect(await henkakuToken.balanceOf(contract.address)).to.be.eq(
        ethers.utils.parseUnits('1000', 18)
      )
    })

    it('mint With henkaku token by alice', async () => {
      await henkakuToken.transfer(
        alice.address,
        ethers.utils.parseUnits('1400', 18)
      )
      const balance = await henkakuToken.balanceOf(alice.address)
      await henkakuToken.connect(alice).approve(contract.address, price)
      expect(await henkakuToken.balanceOf(contract.address)).to.be.eq(0)
      const tx = await contract
        .connect(alice)
        .mintWithHenkaku(
          'https://example.com/podcast.png',
          'joi.eth',
          ethers.utils.parseUnits('1000', 18)
        )
      await tx.wait()
      expect(await contract.balanceOf(alice.address)).to.eq(1)
      expect(await contract.hasRoleOf(alice.address, 'MEMBER')).to.be.true
      expect(await henkakuToken.balanceOf(alice.address)).to.be.eq(
        balance.sub(price)
      )
      expect(await henkakuToken.balanceOf(contract.address)).to.be.eq(
        ethers.utils.parseUnits('1000', 18)
      )
    })
  })
  describe('setFundAddress', () => {
    it('reverts if caller is not the owner', async () => {
      await expect(
        contract.connect(alice).setFundAddress(bob.address)
      ).eventually.to.rejectedWith(Error)
    })

    it('sets fund address correctly', async () => {
      expect(await contract.fundAddress()).to.eq(fundAddress.address)
      await contract.setFundAddress(bob.address)
      expect(await contract.fundAddress()).to.eq(bob.address)
    })
  })

  describe('withdraw', () => {
    beforeEach(async () => {
      await henkakuToken.transfer(
        alice.address,
        ethers.utils.parseUnits('1400', 18)
      )
      const balance = await henkakuToken.balanceOf(alice.address)
      await henkakuToken.connect(alice).approve(contract.address, price)
      const tx = await contract
        .connect(alice)
        .mintWithHenkaku(
          'https://example.com/podcast.png',
          'joi.eth',
          ethers.utils.parseUnits('1000', 18)
        )
      await tx.wait()
    })

    it('reverts if caller is not owner', async () => {
      await expect(
        contract.connect(alice).withdraw()
      ).eventually.to.rejectedWith(Error)
    })

    it('withdraws all henkakus to fundaddress', async () => {
      expect(await henkakuToken.balanceOf(contract.address)).to.be.eq(
        ethers.utils.parseUnits('1000', 18)
      )

      expect(await henkakuToken.balanceOf(fundAddress.address)).to.be.eq(
        ethers.utils.parseUnits('0', 18)
      )
      await contract.withdraw()
      expect(await henkakuToken.balanceOf(fundAddress.address)).to.be.eq(
        ethers.utils.parseUnits('1000', 18)
      )
    })
  })

  describe('burn', () => {
    it('can burn for admin', async () => {
      const mintTx = await contract.mint(
        'https://example.com/podcast.png',
        ['Podcast Contributor'],
        '10000',
        owner.address
      )
      await mintTx.wait()

      const burnTx = await contract.burn(1)
      await burnTx.wait()

      await expect(contract.ownerOf(1)).to.be.revertedWith(
        'ERC721: owner query for nonexistent token'
      )
    })
  })

  describe('checkAnswer', () => {
    beforeEach(async () => {
      await henkakuToken.transfer(
        alice.address,
        ethers.utils.parseUnits('1400', 18)
      )
      const balance = await henkakuToken.balanceOf(alice.address)
      await henkakuToken.connect(alice).approve(contract.address, price)
      const tx = await contract
        .connect(alice)
        .mintWithHenkaku(
          'https://example.com/podcast.png',
          'joi.eth',
          ethers.utils.parseUnits('1000', 18)
        )
      await tx.wait()
      await contract.setKeyword('foobar', parseInt(Date.now() / 1000))
    })
    it('answer was correct and updated point', async () => {
      expect((await contract.getUserAttributes(alice.address)).point).to.eq(0)
      expect(
        (await contract.getUserAttributes(alice.address)).claimableToken
      ).to.eq(0)
      const correct = await contract.connect(alice).checkAnswer('foobar')
      expect((await contract.getUserAttributes(alice.address)).point).to.eq(100)
      expect(
        (await contract.getUserAttributes(alice.address)).claimableToken
      ).to.eq(ethers.utils.parseUnits('100', 18))
    })

    it('revert if user tries to answer twice', async () => {
      expect((await contract.getUserAttributes(alice.address)).point).to.eq(0)
      const correct = await contract.connect(alice).checkAnswer('foobar')
      expect((await contract.getUserAttributes(alice.address)).point).to.eq(100)
      await expect(
        contract.connect(alice).checkAnswer('foobar')
      ).eventually.to.rejectedWith('You cannot answer twice')
    })
  })

  describe('claimToken', () => {
    beforeEach(async () => {
      await henkakuToken.transfer(
        alice.address,
        ethers.utils.parseUnits('1400', 18)
      )
      const balance = await henkakuToken.balanceOf(alice.address)
      await henkakuToken.connect(alice).approve(contract.address, price)
      const tx = await contract
        .connect(alice)
        .mintWithHenkaku(
          'https://example.com/podcast.png',
          'joi.eth',
          ethers.utils.parseUnits('1000', 18)
        )
      await tx.wait()
      await contract.setKeyword('foobar', parseInt(Date.now() / 1000))
      const correct = await contract.connect(alice).checkAnswer('foobar')
    })
    it('claim token successfully', async () => {
      expect(await henkakuToken.balanceOf(alice.address)).to.eq(
        ethers.utils.parseUnits('400', 18)
      )
      const correct = await contract.connect(alice).claimToken()
      expect(
        (await contract.getUserAttributes(alice.address)).claimableToken
      ).to.eq(0)
      expect(await henkakuToken.balanceOf(alice.address)).to.eq(
        ethers.utils.parseUnits('500', 18)
      )
    })

    it('reverts if user doesn not have claimable toke', async () => {
      expect(await henkakuToken.balanceOf(alice.address)).to.eq(
        ethers.utils.parseUnits('400', 18)
      )
      const correct = await contract.connect(alice).claimToken()
      expect(
        (await contract.getUserAttributes(alice.address)).claimableToken
      ).to.eq(0)
      await expect(
        contract.connect(alice).claimToken()
      ).eventually.to.rejectedWith("You don't have claimable token amount")
    })
  })
})
