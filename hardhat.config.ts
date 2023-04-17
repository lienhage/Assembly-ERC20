import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-foundry";
import "@nomicfoundation/hardhat-toolbox";
import "@nomiclabs/hardhat-solhint";
import "dotenv/config";
import "hardhat-gas-reporter";
import "solidity-coverage";

const DEPLOYER_PRIVATE_KEY =
  process.env.DEPLOYER_PRIVATE_KEY ||
  "0000000000000000000000000000000000000000000000000000000000000000";

const ETHERSCAN_API_KEY =
  process.env.ETHERSCAN_API_KEY ||
  "0000000000000000000000000000000000000000000000000000000000000000";

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.13",
    settings: {
      optimizer: {
        enabled: true,
        runs: 10000,
      },
    },
  },
  networks: {
    mainnet: {
      url: `https://eth-mainnet.alchemyapi.io/v2/${process.env.ALCHEMY_MAINNET_API_KEY}`,
      accounts: [`0x${DEPLOYER_PRIVATE_KEY}`],
    },
    goerli: {
      url: `https://eth-goerli.g.alchemy.com/v2/${process.env.ALCHEMY_GOERLI_API_KEY}`,
      chainId: 5,
      accounts: [`0x${DEPLOYER_PRIVATE_KEY}`],
    },
  },
  etherscan: {
    apiKey: `${ETHERSCAN_API_KEY}`,
  },
  gasReporter: {
    enabled: true
  }
};

export default config;
