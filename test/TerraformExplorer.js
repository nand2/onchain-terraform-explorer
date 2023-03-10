const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");

const {terraformsCharactersFontsB64} = require('./TerraformCharactersFonts.js');


// We define a fixture to reuse the same setup in every test.
async function deployFixture() {

  // Contracts are deployed using the first signer/account by default
  [owner, user1] = await ethers.getSigners();

  //
  // Hardhat node / anvil is incredibly slow with mainnet forking and 
  // the Terraform contract, redeploying it here instead
  //

  const TerraformsCharacters = await ethers.getContractFactory("TerraformsCharacters");
  const terraformsCharacters = await TerraformsCharacters.deploy();
  for(let i = 0; i < terraformsCharactersFontsB64; i++) {
    let tx = await terraformsCharacters.addFont(i, terraformsCharacters[i]);
    let txResult = await tx.wait()
  }

  const TerraformsSVG = await ethers.getContractFactory("TerraformsSVG");
  const terraformsSVG = await TerraformsSVG.deploy(terraformsCharacters.address);

  const PerlinNoise = await ethers.getContractFactory("PerlinNoise");
  const perlinNoise = await PerlinNoise.deploy();

  const TerraformsZones = await ethers.getContractFactory("TerraformsZones");
  const terraformsZones = await TerraformsZones.deploy();


  const TerraformsData = await ethers.getContractFactory("TerraformsData");
  const terraformsData = await TerraformsData.deploy(terraformsSVG.address, perlinNoise.address, terraformsZones.address, terraformsCharacters.address);

  const TerraformsAugmentations = await ethers.getContractFactory("TerraformsAugmentations");
  const terraformsAugmentations = await TerraformsAugmentations.deploy();

  const Terraforms = await ethers.getContractFactory("Terraforms");
  const terraforms = await Terraforms.deploy(terraformsData.address, terraformsAugmentations.address);

  let tx = await terraforms.toggleEarly()
  let txResult = await tx.wait()
  tx = await terraforms.togglePause()
  txResult = await tx.wait()

  // If only, I could do that on mainnet....
  let mintCount = 10
  tx = await terraforms.mint(mintCount, {value: ethers.utils.parseEther('0.16').mul(mintCount)})
  txResult = await tx.wait()  

  tx = await terraforms.setSeed()
  txResult = await tx.wait()



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
