// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {

  // Contracts are deployed using the first signer/account by default
  [owner] = await ethers.getSigners();
  console.log("Signer address: ", owner.address)

  // Goerli values
  let linksNetwork = "goerli";
  let terraformsAddress = "0x5A985f13345E820AA9618826B85F74C3986e1463";
  let terraformsDataAddress = "0x76010876050387FA66E28a1883aD73d576D88Bf2";
  let scriptyBuilderAddress = "0xc9AB9815d4D5461F3b53Ebd857b6582E82A45C49";
  let ethfsFileStorageAddress = "0x70a78d91A434C1073D47b2deBe31C184aA8CA9Fa";

  const TerraformNavigator = await ethers.getContractFactory("TerraformNavigator");
  const terraformNavigator = await TerraformNavigator.deploy(linksNetwork, terraformsAddress, terraformsDataAddress, scriptyBuilderAddress, ethfsFileStorageAddress);

  console.log("TerraformNavigator deployed at " + terraformNavigator.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
