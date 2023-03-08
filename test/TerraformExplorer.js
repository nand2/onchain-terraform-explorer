const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");

// We define a fixture to reuse the same setup in every test.
async function deployFixture() {

  // Contracts are deployed using the first signer/account by default
  [owner, user1] = await ethers.getSigners();

  // Mainnet values
  let scriptyStorageAddress = "0x096451F43800f207FC32B4FF86F286EdaF736eE3";
  let scriptyBuilderAddress = "0x16b727a2Fc9322C724F4Bc562910c99a5edA5084";
  let ethfsFileStorageAddress = "0xFc7453dA7bF4d0c739C1c53da57b3636dAb0e11e";

  const TerraformExplorer = await ethers.getContractFactory("TerraformExplorer");
  const terraformExplorer = await TerraformExplorer.deploy(scriptyStorageAddress, scriptyBuilderAddress, ethfsFileStorageAddress);

  console.log("Contract deployed at " + terraformExplorer.address);

  return { terraformExplorer };
}

describe("TerraformExplorer", function () {
  it("Index", async function () {
    const { terraformExplorer } = await loadFixture(deployFixture);

    let gasUsage = await terraformExplorer.connect(user1).estimateGas.indexHTML();
    let result = await terraformExplorer.connect(user1).indexHTML();

    console.log(result);
    console.log("Gas used: ", gasUsage.toNumber())
  });

});
