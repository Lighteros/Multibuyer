import { HardhatUserConfig } from 'hardhat/config'
import '@nomicfoundation/hardhat-toolbox'

import * as dotenv from 'dotenv'
dotenv.config()

const config: HardhatUserConfig = {
  solidity: '0.8.24',
  networks: {
    hardhat: {
      forking: {
        url: `https://rpc.ankr.com/base/bfd2d748f92c127516af8ce39314290c9ae72d33686cdd04e67784b91a4078f6`,
        // url: `https://base-mainnet.g.alchemy.com/v2/${process.env.ALCHEMY_API_KEY}`,
        blockNumber: 11396070,
      },
    },
    base: {
      url: `https://rpc.ankr.com/base/bfd2d748f92c127516af8ce39314290c9ae72d33686cdd04e67784b91a4078f6`,
      // url: `https://base-mainnet.g.alchemy.com/v2/${process.env.ALCHEMY_API_KEY}`,
      accounts: [process.env.PRIVATE_KEY || ''],
    },
  },
}

export default config
