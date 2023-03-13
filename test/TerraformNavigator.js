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
  console.log("TerraformsCharacters deployed at " + terraformsCharacters.address);
  // Anvil fails after the first .addFont() call (timeout), so disabling for now
  for(let i = 0; i < 1 /** terraformsCharactersFontsB64.length */; i++) {
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
  console.log("Terraforms sale toggled");

  // If only, I could do that on mainnet....
  let mintCount = 20
  tx = await terraforms.mint(mintCount)
  txResult = await tx.wait()
  console.log("Terraforms minted");

  tx = await terraforms.setSeed()
  txResult = await tx.wait()
  console.log("Terraforms seeded");


  // Goerli values
  let scriptyStorageAddress = "0x730B0ADaaD15B0551928bAE7011F2C1F2A9CA20C";
  let scriptyBuilderAddress = "0xc9AB9815d4D5461F3b53Ebd857b6582E82A45C49";
  let ethfsFileStorageAddress = "0x70a78d91A434C1073D47b2deBe31C184aA8CA9Fa";

  // // Mainnet values
  // let scriptyStorageAddress = "0x096451F43800f207FC32B4FF86F286EdaF736eE3";
  // let scriptyBuilderAddress = "0x16b727a2Fc9322C724F4Bc562910c99a5edA5084";
  // let ethfsFileStorageAddress = "0xFc7453dA7bF4d0c739C1c53da57b3636dAb0e11e";

  const TerraformNavigator = await ethers.getContractFactory("TerraformNavigator");
  const terraformNavigator = await TerraformNavigator.deploy(terraforms.address, terraformsData.address, terraformsCharacters.address, scriptyBuilderAddress, ethfsFileStorageAddress);

  console.log("Terraforms deployed at " + terraforms.address);
  console.log("TerraformsData deployed at " + terraformsData.address);
  console.log("Contract deployed at " + terraformNavigator.address);

  console.log("Sample terraform HTML: evm://" + terraforms.address + ".5/call/tokenHTML(uint256 tokenId)?tokenId=4")
  console.log("Sample terraform SVG: evm://" + terraforms.address + ".5/call/tokenSVG(uint256).svg?arg=4")
  console.log("Sample terraformData levelAndTile: evm://" + terraformsData.address + ".5/call/levelAndTile(uint256,uint256)(uint256,uint256).txt?arg=2&arg=50");
  console.log("Index URL: evm://" + terraformNavigator.address + '.5/call/indexHTML(uint256)?arg=1');

  return { terraformNavigator };
}

describe("TerraformNavigator", function () {
  it("Index", async function () {
    // const { terraformNavigator } = await loadFixture(deployFixture); // only with hardhat node
    const { terraformNavigator } = await deployFixture();

    let gasUsage = await terraformNavigator.connect(user1).estimateGas.indexHTML(1);
    let result = await terraformNavigator.connect(user1).indexHTML(1);

    // console.log(result);
    console.log("Gas used: ", gasUsage.toNumber())
  });

});
