// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {

  // Create a Frame connection
  const ethProvider = require('eth-provider') // eth-provider is a simple EIP-1193 provider
  const frame = ethProvider('frame') // Connect to Frame
  
  // Mainnet values
  let terraformsAddress = "0x4E1f41613c9084FdB9E34E11fAE9412427480e56";
  let terraformsDataAddress = "0xA5aFC9fE76a28fB12C60954Ed6e2e5f8ceF64Ff2";
  let terraformsCharactersAddress = "0xC9e417B7e67E387026161E50875D512f29630D7B";
  let scriptyBuilderAddress = "0x16b727a2Fc9322C724F4Bc562910c99a5edA5084";
  let ethfsFileStorageAddress = "0xFc7453dA7bF4d0c739C1c53da57b3636dAb0e11e";

  const TerraformNavigator = await ethers.getContractFactory("TerraformNavigator");
  const tx = await TerraformNavigator.getDeployTransaction(terraformsAddress, terraformsDataAddress, terraformsCharactersAddress, scriptyBuilderAddress, ethfsFileStorageAddress);

  // Set `tx.from` to current Frame account
  tx.from = (await frame.request({ method: 'eth_requestAccounts' }))[0]
  console.log("Signer address: ", tx.from)

  // Sign and send the transaction using Frame
  let result = await frame.request({ method: 'eth_sendTransaction', params: [tx] })

  console.log("TerraformNavigator deployed via tx " + result)
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
