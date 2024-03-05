import { loadFixture } from '@nomicfoundation/hardhat-toolbox/network-helpers'
import { expect } from 'chai'
import { ethers } from 'hardhat'

describe('batch', () => {
  const deploy = async () => {
    const [owner, otherAccount] = await ethers.getSigners()

    const buyerFactory = await ethers.getContractFactory('Buyer')
    const buyer = await buyerFactory.deploy()
    await buyer.waitForDeployment()

    const Factory = await ethers.getContractFactory('BuyerFactory')
    const factory = await Factory.deploy(await buyer.getAddress(), 10)
    await factory.waitForDeployment()

    return { factory, owner, otherAccount }
  }

  describe('deployment', () => {
    it('correctly deploy clones', async () => {
      const { factory, owner } = await loadFixture(deploy)
      console.log(await factory.getAddress())
      expect(await factory.owner()).to.equal(owner.address)
      expect(await factory.numberOfClones()).to.equal(10)
    })

    it('batch buyv2 with clones', async () => {
      const { factory, owner, otherAccount } = await loadFixture(deploy)
      await (
        await factory.batchBuyV2(
          10,
          ethers.parseEther('0.001'),
          '0x6BDED42c6DA8FBf0d2bA55B2fa120C5e0c8D7891',
          ethers.parseUnits('0.01', 6),
          [
            '0x4200000000000000000000000000000000000006',
            '0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913',
          ],
          { value: ethers.parseEther('0.01') }
        )
      ).wait()

      await (
        await factory.withdrawAllToken(
          '0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913',
          owner.address
        )
      ).wait()

      await (await factory.withdrawAllETH(owner.address)).wait()

      const USDC = new ethers.Contract(
        '0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913',
        ['function balanceOf(address) external view returns (uint256)'],
        owner
      )

      expect(await USDC.balanceOf(owner.address)).to.equal(
        ethers.parseUnits('0.1', 6)
      )
    })

    it('batch buyv3 with clones', async () => {
      const { factory, owner, otherAccount } = await loadFixture(deploy)
      const clones = await factory.allClones()
      await (
        await factory.batchBuyV3ExactInput(
          10,
          ethers.parseEther('0.0001'),
          '0x2626664c2603336E57B271c5C0b26F421741e481',
          ethers.parseEther('0.0001'),
          '0x4200000000000000000000000000000000000006',
          '0xd9aAEc86B65D86f6A7B5B1b0c42FFA531710b6CA',
          500,
          0,
          { value: ethers.parseEther('0.001') }
        )
      ).wait()

      // const router = new ethers.Contract(
      //   '0x2626664c2603336E57B271c5C0b26F421741e481',
      //   [
      //     'function exactInputSingle((address,address,uint24,address,uint256,uint256,uint160)) external payable returns (uint256 amountOut)',
      //   ],
      //   owner
      // )

      // await (
      //   await router.exactInputSingle(
      //     [
      //       '0x4200000000000000000000000000000000000006',
      //       '0xd9aAEc86B65D86f6A7B5B1b0c42FFA531710b6CA',
      //       500,
      //       clones[0],
      //       ethers.parseEther('0.0001'),
      //       0,
      //       0,
      //     ],
      //     { value: ethers.parseEther('0.001') }
      //   )
      // ).wait()

      // await (
      //   await factory.withdrawAllToken(
      //     '0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913',
      //     owner.address
      //   )
      // ).wait()

      // await (await factory.withdrawAllETH(owner.address)).wait()

      // const USDC = new ethers.Contract(
      //   '0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913',
      //   ['function balanceOf(address) external view returns (uint256)'],
      //   owner
      // )

      // expect(await USDC.balanceOf(owner.address)).to.equal(
      //   ethers.parseUnits('0.1', 6)
      // )
    })
  })
})
