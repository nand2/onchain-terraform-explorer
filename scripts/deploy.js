// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {

  // Mainnet values
  let scriptyStorageAddress = "0x096451F43800f207FC32B4FF86F286EdaF736eE3";
  let scriptyBuilderAddress = "0x16b727a2Fc9322C724F4Bc562910c99a5edA5084";
  let ethfsFileStorageAddress = "0xFc7453dA7bF4d0c739C1c53da57b3636dAb0e11e";

  const TerraformExplorer = await hre.ethers.getContractFactory("TerraformExplorer");
  const terraformExplorer = await TerraformExplorer.deploy(scriptyStorageAddress, scriptyBuilderAddress, ethfsFileStorageAddress);

  await terraformExplorer.deployed();

  console.log(
    `Deployed  to ${terraformExplorer.address}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
