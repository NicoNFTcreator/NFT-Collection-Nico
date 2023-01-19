const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { assert, expect } = require("chai");
const { ethers } = require("hardhat");

describe("NicoWhitelist", function () {
  async function deployContractAndSetVariables() {
    const Nicowhitelist = await ethers.getContractFactory("NicoWhitelist");
    const nicowhitelist = await Nicowhitelist.deploy(50);
    const signer = ethers.provider.getSigner(0);
    //const address = await signer.getAddress();

    return { nicowhitelist, signer };
  }
  it("should add address to whitelist", async function () {
    const { nicowhitelist, signer } = await loadFixture(
      deployContractAndSetVariables
    );
    let max = 0;

    while (max < 50) {
      const wallet = new ethers.Wallet.createRandom().connect(ethers.provider);
      console.log(wallet.address);
      await signer.sendTransaction({
        to: wallet.address,
        value: ethers.utils.parseEther("1"),
      });
      await nicowhitelist.connect(wallet).addAddressToWhitelist();
      max++;
      console.log(max);
      if (max == 50) {
        await expect(
          nicowhitelist.addAddressToWhitelist()
        ).to.be.revertedWithCustomError(
          nicowhitelist,
          "WhitelistSpotsSoldOut"
        ).withArgs(50);
      }
    }
  });
});
