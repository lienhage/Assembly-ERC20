import { ethers } from "hardhat";
import { expect } from "chai";
import { utils } from "ethers";
const { parseEther } = utils;
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { AssemblyERC20 } from "../typechain-types";

describe("AssemblyERC20", function () {
  async function deployFixture() {
    let token: AssemblyERC20;
    let tokenFactory = await ethers.getContractFactory("AssemblyERC20");
    token = await tokenFactory.deploy("Assembly ERC20 Token", "AET");
    let [deployer, user] = await ethers.getSigners();
    return { token, deployer, user };
  }

  describe("Functionality", function () {
    it("Contructor", async function () {
      const { token } = await loadFixture(deployFixture);
      expect(await token.name()).to.be.equal("Assembly ERC20 Token");
      expect(await token.symbol()).to.be.equal("AET");
    });

    it("Should mint", async function () {
      const { token, deployer } = await loadFixture(deployFixture);
      await token.connect(deployer).mint(deployer.address, parseEther("100"));
      expect(await token.balanceOf(deployer.address)).to.be.equal(
        parseEther("100")
      );
      await token.connect(deployer).mint(deployer.address, parseEther("100"));
      expect(await token.balanceOf(deployer.address)).to.be.equal(
        parseEther("200")
      );
    });

    it("Should burn", async function () {
      const { token, deployer } = await loadFixture(deployFixture);
      await token.connect(deployer).mint(deployer.address, parseEther("100"));
      await token.connect(deployer).burn(deployer.address, parseEther("10"));
      expect(await token.balanceOf(deployer.address)).to.be.equal(
        parseEther("90")
      );
      await token.connect(deployer).burn(deployer.address, parseEther("90"));
      expect(await token.balanceOf(deployer.address)).to.be.equal(
        parseEther("0")
      );
      await expect(
        token.connect(deployer).burn(deployer.address, parseEther("90"))
      ).to.be.reverted;
    });

    it("Should approve", async function () {
      const { token, deployer, user } = await loadFixture(deployFixture);
      await token.connect(deployer).approve(user.address, parseEther("100"));
      expect(await token.allowance(deployer.address, user.address)).to.be.equal(
        parseEther("100")
      );
      await token.connect(deployer).approve(user.address, parseEther("150"));
      expect(await token.allowance(deployer.address, user.address)).to.be.equal(
        parseEther("150")
      );
      await token.connect(deployer).approve(user.address, parseEther("0"));
      expect(await token.allowance(deployer.address, user.address)).to.be.equal(
        parseEther("0")
      );
    });

    it("Should transfer", async function () {
      const { token, deployer, user } = await loadFixture(deployFixture);
      await token.connect(deployer).mint(deployer.address, parseEther("100"));
      expect(await token.balanceOf(deployer.address)).to.be.equal(
        parseEther("100")
      );
      await token.connect(deployer).transfer(user.address, parseEther("10"));
      expect(await token.balanceOf(deployer.address)).to.be.equal(
        parseEther("90")
      );
      expect(await token.balanceOf(user.address)).to.be.equal(parseEther("10"));

      await token.connect(deployer).transfer(user.address, parseEther("10"));
      expect(await token.balanceOf(deployer.address)).to.be.equal(
        parseEther("80")
      );
      expect(await token.balanceOf(user.address)).to.be.equal(parseEther("20"));

      await token.connect(deployer).transfer(user.address, parseEther("80"));
      expect(await token.balanceOf(deployer.address)).to.be.equal(
        parseEther("0")
      );
      expect(await token.balanceOf(user.address)).to.be.equal(
        parseEther("100")
      );
    });

    it("Should transferFrom", async function () {
      const { token, deployer, user } = await loadFixture(deployFixture);
      await token.connect(deployer).mint(deployer.address, parseEther("100"));
      expect(await token.balanceOf(deployer.address)).to.be.equal(
        parseEther("100")
      );

      await token.connect(deployer).approve(user.address, parseEther("100"));
      await token
        .connect(user)
        .transferFrom(deployer.address, user.address, parseEther("10"));
      expect(await token.balanceOf(deployer.address)).to.be.equal(
        parseEther("90")
      );
      expect(await token.balanceOf(user.address)).to.be.equal(parseEther("10"));

      await token
        .connect(user)
        .transferFrom(deployer.address, user.address, parseEther("10"));
      expect(await token.balanceOf(deployer.address)).to.be.equal(
        parseEther("80")
      );
      expect(await token.balanceOf(user.address)).to.be.equal(parseEther("20"));

      await token
        .connect(user)
        .transferFrom(deployer.address, user.address, parseEther("80"));
      expect(await token.balanceOf(deployer.address)).to.be.equal(
        parseEther("0")
      );
      expect(await token.balanceOf(user.address)).to.be.equal(
        parseEther("100")
      );
    });
  });
});
