// We need terraforms on Goerli!

const hre = require("hardhat");
const {terraformsCharactersFontsB64} = require('../test/TerraformCharactersFonts.js');

async function main() {

  // Contracts are deployed using the first signer/account by default
  [owner] = await ethers.getSigners();
  console.log("Signer address: ", owner.address)

  const TerraformsCharacters = await ethers.getContractFactory("TerraformsCharacters");
  const terraformsCharacters = await TerraformsCharacters.deploy();

  console.log("TerraformsCharacters deployed at " + terraformsCharacters.address);
  for(let i = 2; i < terraformsCharactersFontsB64.length; i++) {
    let tx = await terraformsCharacters.addFont(i, terraformsCharactersFontsB64[i]);
    let txResult = await tx.wait()
    console.log("TerraformsCharacters font " + i + ' added');
  }

  const TerraformsSVG = await ethers.getContractFactory("TerraformsSVG");
  const terraformsSVG = await TerraformsSVG.deploy(terraformsCharacters.address);
  console.log("TerraformsSVG deployed at " + terraformsSVG.address);

  const PerlinNoise = await ethers.getContractFactory("PerlinNoise");
  const perlinNoise = await PerlinNoise.deploy();
  console.log("PerlinNoise deployed at " + perlinNoise.address);

  const TerraformsZones = await ethers.getContractFactory("TerraformsZones");
  const terraformsZones = await TerraformsZones.deploy();
  console.log("TerraformsZones deployed at " + terraformsZones.address);

  const TerraformsData = await ethers.getContractFactory("TerraformsData");
  const terraformsData = await TerraformsData.deploy(terraformsSVG.address, perlinNoise.address, terraformsZones.address, terraformsCharacters.address);  
  console.log("TerraformsData deployed at " + terraformsData.address);

  const TerraformsAugmentations = await ethers.getContractFactory("TerraformsAugmentations");
  const terraformsAugmentations = await TerraformsAugmentations.deploy();
  console.log("TerraformsAugmentations deployed at " + terraformsAugmentations.address);

  const Terraforms = await ethers.getContractFactory("Terraforms");
  const terraforms = await Terraforms.deploy(terraformsData.address, terraformsAugmentations.address);
  console.log("Terraforms deployed at " + terraforms.address);


  let tx = await terraforms.toggleEarly()
  let txResult = await tx.wait()
  tx = await terraforms.togglePause()
  txResult = await tx.wait()

  // If only, I could do that on mainnet....
  let mintCount = 20
  tx = await terraforms.mint(mintCount)
  txResult = await tx.wait()  

  tx = await terraforms.setSeed()
  txResult = await tx.wait()

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
