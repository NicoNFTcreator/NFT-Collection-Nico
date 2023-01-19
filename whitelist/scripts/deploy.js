const { ethers } = require("hardhat");
const hre = require("hardhat");

async function main() {
  const whitelist = await ethers.getContractFactory("NicoWhitelist");
  // nombre max de whitelist a changé lors du passage en mainnet
  // je l'ai laissé à 3 pour tester
  const Whitelist = await whitelist.deploy(3);
  await Whitelist.deployed();

  console.log("Whitelist deployed at:", Whitelist.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
