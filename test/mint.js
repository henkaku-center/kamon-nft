const chai = require('chai')
const { expect } = chai
const { ethers } = require('hardhat')
const chaiAsPromised = require('chai-as-promised')

chai.use(chaiAsPromised)
describe('KamonNFT', function () {
  let Contract, contract, HenkakuToken, henkakuToken
  let owner, alice, bob, fundAddress, price

  beforeEach(async function () {
    HenkakuToken = await ethers.getContractFactory('MockERC20')
    henkakuToken = await HenkakuToken.deploy()
    await henkakuToken.deployed()
    price = ethers.utils.parseUnits('1000', 18)

    Contract = await ethers.getContractFactory('KamonNFT')
    ;[owner, alice, bob, fundAddress] = await ethers.getSigners()
    contract = await Contract.deploy(henkakuToken.address, fundAddress.address)
    await contract.deployed()
  })

  describe('setHenkakuToken', () => {
    it('revert if user is not owner', async () => {
      const henkakuToken2 = await HenkakuToken.deploy()
      await henkakuToken2.deployed()
      await expect(contract.connect(alice).setTokenAddr(henkakuToken2.address))
        .to.be.reverted
    })

    it('owner set token address correctly', async () => {
      const henkakuToken2 = await HenkakuToken.deploy()
      await henkakuToken2.deployed()

      expect(await contract.henkakuToken()).to.be.equal(henkakuToken.address)
      let tx = await contract.setTokenAddr(henkakuToken2.address)
      tx.wait()
      expect(await contract.henkakuToken()).to.be.equal(henkakuToken2.address)
    })
  })

  describe('roles', () => {
    it('revert if user does not hold', async () => {
      await expect(contract.roles(alice.address, 0)).to.be.reverted
    })
    it('can retrieve roles', async () => {
      const mintTx = await contract.mint(
        'https://example.com/podcast.png',
        ['Podcast Contributor', 'MEMBER'],
        alice.address
      )
      await mintTx.wait()
      expect(await contract.ownerOf(1)).to.be.equal(alice.address)
      expect(await contract.roles(alice.address, 0)).to.eq(
        'Podcast Contributor'
      )
      expect(await contract.roles(alice.address, 1)).to.eq('MEMBER')
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
      ).to.be.revertedWith('MUST BE HOLDER')
    })
    it('add roles correctly', async () => {
      const mintTx = await contract.mint(
        'https://example.com/podcast.png',
        ['Podcast Contributor'],
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
      ).to.be.revertedWith('MUST BE HOLDER')
    })
    it('add empty roles', async () => {
      const mintTx = await contract.mint(
        'https://example.com/podcast.png',
        ['Podcast Contributor'],
        alice.address
      )
      await mintTx.wait()
      expect(await contract.hasRoleOf(alice.address, 'MEMBER')).to.be.false
      await contract.setRoles(alice.address, [])
      await expect(contract.roles(alice.address, 0)).to.be.reverted
    })
    it('add roles correctly', async () => {
      const mintTx = await contract.mint(
        'https://example.com/podcast.png',
        ['Podcast Contributor'],
        alice.address
      )
      await mintTx.wait()
      expect(await contract.hasRoleOf(alice.address, 'MEMBER')).to.be.false
      await contract.setRoles(alice.address, ['MEMBER', 'ADMIN'])
      expect(await contract.roles(alice.address, 0)).to.eq('MEMBER')
      expect(await contract.roles(alice.address, 1)).to.eq('ADMIN')
    })
  })

  describe('mint', () => {
    it('can mint for admin', async function () {
      const mintTx = await contract.mint(
        'https://example.com/podcast.png',
        ['Podcast Contributor'],
        alice.address
      )
      await mintTx.wait()
      expect(await contract.ownerOf(1)).to.be.equal(alice.address)
    })

    it('cannot mint twice for the same user(owner)', async function () {
      const mintTx = await contract.mint(
        'https://example.com/podcast.png',
        ['Podcast Contributor'],
        alice.address
      )
      await mintTx.wait()
      await expect(
        contract.mint(
          'https://example.com/podcast.png',
          ['Podcast Contributor'],
          alice.address
        )
      ).eventually.to.rejectedWith(Error)
    })
  })

  describe('setPrice', () => {
    it('reverts with less amount', async () => {
      await expect(
        contract.setPrice(ethers.utils.parseUnits('1', 17))
      ).eventually.to.rejectedWith('MUST BE GTE 1e18')
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

  describe('setRewardPoint', () => {
    it('reverts when normal user try to change', async () => {
      await expect(
        contract.connect(alice).setRewardPoint(1000)
      ).eventually.to.rejectedWith(Error)
    })

    it('sets point correctly', async () => {
      expect(await contract.rewardPoint()).to.eq(100)
      await contract.setRewardPoint(500)
      expect(await contract.rewardPoint()).to.eq(500)
    })
  })

  describe('setRewardHenkaku', () => {
    it('reverts with less amount', async () => {
      await expect(
        contract.setRewardHenkaku(ethers.utils.parseUnits('1', 17))
      ).eventually.to.rejectedWith('MUST BE GTE 1e18')
    })

    it('reverts when normal user try to change', async () => {
      await expect(
        contract
          .connect(alice)
          .setRewardHenkaku(ethers.utils.parseUnits('500', 18))
      ).eventually.to.rejectedWith(Error)
    })

    it('sets henkaku correctly', async () => {
      expect(await contract.rewardHenkaku()).to.eq(
        ethers.utils.parseUnits('100', 18)
      )
      await contract.setRewardHenkaku(ethers.utils.parseUnits('500', 18))
      expect(await contract.rewardHenkaku()).to.eq(
        ethers.utils.parseUnits('500', 18)
      )
    })
  })

  describe('mintWithHenkaku', () => {
    it('revert without approval', async () => {
      await expect(
        contract.mintWithHenkaku(
          'https://example.com/podcast.png',
          ethers.utils.parseUnits('1000', 18)
        )
      ).eventually.to.rejectedWith(Error)
    })

    it('revert if you have more than 1 membershipNFT', async () => {
      await henkakuToken.transfer(
        alice.address,
        ethers.utils.parseUnits('3000', 18)
      )
      await henkakuToken.connect(alice).approve(contract.address, price)
      const tx = await contract
        .connect(alice)
        .mintWithHenkaku(
          'https://example.com/podcast.png',
          ethers.utils.parseUnits('1000', 18)
        )
      await tx.wait()
      expect(await contract.balanceOf(alice.address)).to.eq(1)
      await expect(
        contract
          .connect(alice)
          .mintWithHenkaku(
            'https://example.com/podcast.png',
            ethers.utils.parseUnits('1000', 18)
          )
      ).eventually.to.rejectedWith('MUST BE NONE HOLDER')
    })

    it('revert if you try to buy with less price', async () => {
      await henkakuToken.transfer(
        alice.address,
        ethers.utils.parseUnits('1400', 18)
      )
      await henkakuToken.connect(alice).approve(contract.address, price)
      await expect(
        contract
          .connect(alice)
          .mintWithHenkaku(
            'https://example.com/podcast.png',
            ethers.utils.parseUnits('900', 18)
          )
      ).eventually.to.rejectedWith('INSUFFICIENT AMOUNT')
    })

    it('mint with henkaku token', async () => {
      const balance = await henkakuToken.balanceOf(owner.address)
      await henkakuToken.approve(contract.address, price)
      expect(await henkakuToken.balanceOf(contract.address)).to.be.eq(0)
      const tx = await contract.mintWithHenkaku(
        'https://example.com/podcast.png',
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
      expect(await contract.totalSupply()).to.eq(1)
    })

    it('mint with henkaku token by alice', async () => {
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
      expect(await contract.totalSupply()).to.eq(1)
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
      await henkakuToken.connect(alice).approve(contract.address, price)
      const tx = await contract
        .connect(alice)
        .mintWithHenkaku(
          'https://example.com/podcast.png',
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
      await henkakuToken.connect(alice).approve(contract.address, price)
      const tx = await contract
        .connect(alice)
        .mintWithHenkaku(
          'https://example.com/podcast.png',
          ethers.utils.parseUnits('1000', 18)
        )
      await tx.wait()
      const keyword = ethers.utils.keccak256(ethers.utils.toUtf8Bytes('foobar'))
      await contract.setKeyword(keyword, parseInt(Date.now() / 1000))
    })

    it('answer was correct and updated point', async () => {
      expect((await contract.userAttribute(alice.address)).point).to.eq(0)
      expect(
        (await contract.userAttribute(alice.address)).claimableToken
      ).to.eq(0)
      const tx = await contract.connect(alice).checkAnswer('foobar')
      await expect(tx).to.emit(contract, 'CheckedAnswer')
      expect((await contract.userAttribute(alice.address)).point).to.eq(100)
      expect(
        (await contract.userAttribute(alice.address)).claimableToken
      ).to.eq(ethers.utils.parseUnits('100', 18))
    })

    it('revert if user tries to answer twice', async () => {
      expect((await contract.userAttribute(alice.address)).point).to.eq(0)
      const tx = await contract.connect(alice).checkAnswer('foobar')
      await expect(tx).to.emit(contract, 'CheckedAnswer')
      expect((await contract.userAttribute(alice.address)).point).to.eq(100)
      await expect(
        contract.connect(alice).checkAnswer('foobar')
      ).eventually.to.rejectedWith('ALREADY ANSWERED')
    })
  })

  describe('claimToken', () => {
    beforeEach(async () => {
      await henkakuToken.transfer(
        alice.address,
        ethers.utils.parseUnits('1400', 18)
      )
      await henkakuToken.connect(alice).approve(contract.address, price)
      const tx = await contract
        .connect(alice)
        .mintWithHenkaku(
          'https://example.com/podcast.png',
          ethers.utils.parseUnits('1000', 18)
        )
      await tx.wait()
      const keyword = ethers.utils.keccak256(ethers.utils.toUtf8Bytes('foobar'))
      await contract.setKeyword(keyword, parseInt(Date.now() / 1000))
      await contract.connect(alice).checkAnswer('foobar')
    })

    it('claim token successfully', async () => {
      expect(await henkakuToken.balanceOf(alice.address)).to.eq(
        ethers.utils.parseUnits('400', 18)
      )
      await contract.connect(alice).claimToken()
      expect(
        (await contract.userAttribute(alice.address)).claimableToken
      ).to.eq(0)
      expect(await henkakuToken.balanceOf(alice.address)).to.eq(
        ethers.utils.parseUnits('500', 18)
      )
    })

    it('reverts if user doesn not have claimable toke', async () => {
      expect(await henkakuToken.balanceOf(alice.address)).to.eq(
        ethers.utils.parseUnits('400', 18)
      )
      await contract.connect(alice).claimToken()
      expect(
        (await contract.userAttribute(alice.address)).claimableToken
      ).to.eq(0)
      await expect(
        contract.connect(alice).claimToken()
      ).eventually.to.rejectedWith('INSUFFICIENT AMOUNT')
    })
  })

  describe('giveAwayPoint', () => {
    it('revert without nft', async () => {
      await expect(
        contract.setRoles(alice.address, ['MEMBER', 'ADMIN'])
      ).to.be.revertedWith('MUST BE HOLDER')
    })

    it('has 0 points at first', async () => {
      const mintTx = await contract.mint(
        'https://example.com/podcast.png',
        ['Podcast Contributor'],
        alice.address
      )
      await mintTx.wait()
      expect((await contract.userAttribute(alice.address)).point).to.eq(0)
      expect(
        (await contract.userAttribute(alice.address)).claimableToken
      ).to.eq(0)
    })

    it('can grant 100 points', async () => {
      const mintTx = await contract.mint(
        'https://example.com/podcast.png',
        ['Podcast Contributor'],
        alice.address
      )
      await mintTx.wait()
      await contract.giveAwayPoint(
        alice.address,
        100,
        ethers.utils.parseUnits('100', 18)
      )
      expect((await contract.userAttribute(alice.address)).point).to.eq(100)
      expect(
        (await contract.userAttribute(alice.address)).claimableToken
      ).to.eq(ethers.utils.parseUnits('100', 18))
    })

    it('can grant 0 points', async () => {
      const mintTx = await contract.mint(
        'https://example.com/podcast.png',
        ['Podcast Contributor'],
        alice.address
      )
      await mintTx.wait()
      await contract.giveAwayPoint(
        alice.address,
        0,
        ethers.utils.parseUnits('0', 18)
      )
      expect((await contract.userAttribute(alice.address)).point).to.eq(0)
      expect(
        (await contract.userAttribute(alice.address)).claimableToken
      ).to.eq(ethers.utils.parseUnits('0', 18))
    })
  })

  describe('transfer', async () => {
    it('revert if transfer by non-owner', async () => {
      const mintTx = await contract.mint(
        'https://example.com/podcast.png',
        ['Podcast Contributor', 'MEMBER'],
        alice.address
      )
      await mintTx.wait()

      expect(
        contract.connect(alice).transferFrom(alice.address, bob.address, 1)
      ).to.be.revertedWith('Ownable: caller is not the owner')
    })

    it('can transfer', async () => {
      const roles = ['Podcast Contributor', 'MEMBER']
      const mintTx = await contract.mint(
        'https://example.com/podcast.png',
        roles,
        alice.address
      )
      await mintTx.wait()

      const point = 100
      const claimableToken = ethers.utils.parseUnits('100', 18)
      const giveAwayPointTx = await contract.giveAwayPoint(
        alice.address,
        point,
        claimableToken
      )
      await giveAwayPointTx.wait()

      const transferTx = await contract.transferFrom(
        alice.address,
        bob.address,
        1
      )
      await transferTx.wait()

      expect(await contract.balanceOf(alice.address)).to.eq(0)
      expect(contract.roles(alice.address, 0)).to.be.reverted
      expect(contract.userAttribute(alice.address)).to.be.reverted
      expect(await contract.balanceOf(bob.address)).to.eq(1)
      expect(await contract.roles(bob.address, 0)).to.eq(roles[0])
      expect(await contract.roles(bob.address, 1)).to.eq(roles[1])
      expect((await contract.userAttribute(bob.address)).point).to.eq(point)
      expect((await contract.userAttribute(bob.address)).claimableToken).to.eq(
        claimableToken
      )
    })
  })

  describe('emit', () => {
    it('can emit BoughtMemberShipNFT', async () => {
      await henkakuToken.transfer(
        alice.address,
        ethers.utils.parseUnits('1400', 18)
      )
      await henkakuToken.connect(alice).approve(contract.address, price)

      await expect(
        contract
          .connect(alice)
          .mintWithHenkaku(
            'https://example.com/podcast.png',
            ethers.utils.parseUnits('1000', 18)
          )
      )
        .to.emit(contract, 'BoughtMemberShipNFT')
        .withArgs(alice.address, 1)
    })
  })

  describe('updateNFT', async () => {
    it('revert if not the owner', async () => {
      const mintTx = await contract.mint(
        'https://example.com/podcast.png',
        ['Podcast Contributor'],
        alice.address
      )
      await mintTx.wait()

      await expect(
        contract.connect(alice).updateNFT(1, 'https://example.com/new.png')
      ).to.be.reverted
    })

    it('can update tokenURI', async () => {
      const mintTx = await contract.mint(
        'https://example.com/podcast.png',
        ['Podcast Contributor'],
        alice.address
      )
      await mintTx.wait()
      expect(await contract.tokenURI(1)).to.be.equal(
        'https://example.com/podcast.png'
      )

      const updateTx = await contract.updateNFT(
        1,
        'https://example.com/new.png'
      )
      await updateTx.wait()
      expect(await contract.tokenURI(1)).to.be.equal(
        'https://example.com/new.png'
      )
    })
  })

  describe('updateOwnNFT', async () => {
    it('revert if not the NFT owner', async () => {
      const mintTx1 = await contract.mint(
        'https://example.com/podcast.png',
        ['Podcast Contributor'],
        alice.address
      )
      await mintTx1.wait()

      const mintTx2 = await contract.mint(
        'https://example.com/podcast.png',
        ['Podcast Contributor'],
        owner.address
      )
      await mintTx2.wait()

      await expect(
        contract.connect(owner).updateOwnNFT(1, 'https://example.com/new.png')
      ).to.be.reverted
    })

    it('can update tokenURI', async () => {
      const mintTx = await contract.mint(
        'https://example.com/podcast.png',
        ['Podcast Contributor'],
        alice.address
      )
      await mintTx.wait()
      expect(await contract.tokenURI(1)).to.be.equal(
        'https://example.com/podcast.png'
      )

      const updateTx = await contract
        .connect(alice)
        .updateOwnNFT(1, 'https://example.com/new.png')
      await updateTx.wait()
      expect(await contract.tokenURI(1)).to.be.equal(
        'https://example.com/new.png'
      )
    })
  })

  describe('setContractURI', () => {
    it('reverts if caller is not the owner', async () => {
      await expect(
        contract
          .connect(alice)
          .setContractURI('https://metadata-url.com/my-metadata')
      ).eventually.to.rejectedWith(Error)
    })

    it('sets contract URI correctly', async () => {
      expect(await contract.contractURI()).to.eq('')
      await contract.setContractURI('https://metadata-url.com/my-metadata')
      expect(await contract.contractURI()).to.eq(
        'https://metadata-url.com/my-metadata'
      )
    })
  })
})
