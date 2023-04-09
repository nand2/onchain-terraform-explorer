require("@nomicfoundation/hardhat-toolbox");
require('hardhat-contract-sizer');
require("@nomiclabs/hardhat-etherscan");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
    solidity: {
        version: "0.8.18",
        settings: {
            optimizer: {
                enabled: true,
                runs: 200,
                details: {
                    yul: false
                }
            },
        },
    },
    networks: {
        // goerli: {
        //     url: process.env.GOERLI_URL,
        //     // accounts: [process.env.GOERLI_PRIVATE_KEY],
        // }
        // mainnet: {
        //     url: process.env.MAINNET_URL,
        // }
    },
    mocha: {
        timeout: 200000
    },
  etherscan: {
    // Your API key for Etherscan
    // Obtain one at https://etherscan.io/
    apiKey: process.env.ETHERSCAN_API_KEY
  }
};
