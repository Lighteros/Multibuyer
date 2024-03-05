import { ethers } from 'hardhat'

async function main() {
  const [signer] = await ethers.getSigners()

  const buyerFactory = await ethers.getContractFactory('Buyer')
  const buyer = await buyerFactory.deploy()
  await buyer.waitForDeployment()

  const Factory = await ethers.getContractFactory('BuyerFactory')
  const factory = await Factory.deploy(await buyer.getAddress(), 10)
  await factory.waitForDeployment()

  console.log(await factory.getAddress())
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
