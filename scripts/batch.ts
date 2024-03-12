import { ethers } from 'hardhat'

async function main() {
  const [signer] = await ethers.getSigners()

  const factory = await ethers.getContractAt(
    'BuyerFactory',
    '0x67a20fd8c6520ee2509624d60382266fe3614310',
    signer
  )

  console.log('owner = ', await factory.owner())
  console.log('num of clones = ', await factory.numberOfClones())
  console.log(await factory.allClones())

  await (
    await factory.batchBuyV2(
      10,
      ethers.parseEther('0.002'),
      '0x4752ba5dbc23f44d87826276bf6fd6b1c372ad24',
      ethers.parseUnits('1', 9),
      [
        '0x4200000000000000000000000000000000000006',
        '0xB1225765D5A1a8a956300320Df25e9D033709346',
      ],
      { value: ethers.parseEther('0.02') }
    )
  ).wait()

  // await (
  //   await factory.batchBuyV3ExactInput(
  //     10,
  //     ethers.parseEther('0.1'),
  //     '0x2626664c2603336E57B271c5C0b26F421741e481',
  //     ethers.parseEther('0.1'),
  //     '0x4200000000000000000000000000000000000006',
  //     '0xd9aAEc86B65D86f6A7B5B1b0c42FFA531710b6CA',
  //     500,
  //     0,
  //     { value: ethers.parseEther('1') }
  //   )
  // ).wait()

  // await (
  //   await factory.withdrawAllToken(
  //     '0xd9aAEc86B65D86f6A7B5B1b0c42FFA531710b6CA',
  //     signer.address
  //   )
  // ).wait()

  // await (await factory.withdrawAllETH(signer.address)).wait()
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
