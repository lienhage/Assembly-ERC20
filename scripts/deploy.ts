import { ethers } from "hardhat";

async function main() {
  const ERC20Factory = await ethers.getContractFactory("AssemblyERC20");
  const ERC20 = await ERC20Factory.deploy(
    "BUSDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD",
    "BUSD"
  );
  // await ERC20.name()
  console.log(await ERC20.name());
  console.log(await ERC20.decimals());
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
