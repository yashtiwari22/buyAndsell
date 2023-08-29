const { expect } = require("chai");
describe("CustomToken", function () {
  let CustomToken, customToken, owner, addr1, addr2;

  beforeEach(async function () {
    CustomToken = await ethers.getContractFactory("CustomToken");
    [owner, addr1, addr2] = await ethers.getSigners();
    customToken = await CustomToken.deploy();
    await customToken.waitForDeployment();
  });

  it("Should allow transfers", async function () {
    await customToken.transfer(addr1.address, 1000);
    expect(await customToken.balanceOf(addr1.address)).to.equal(990);
  });

  it("Should apply deflationary mechanism on transfer", async function () {
    await customToken.transfer(addr1.address, 1000);
    const balanceAfterTransfer = await customToken.balanceOf(addr1.address);
    expect(balanceAfterTransfer).to.be.lessThan(1000);
  });

  it("Should allow burning tokens", async function () {
    await customToken.burnTokens(500);
    const initialSupply = BigInt("999999999999999999999500");
    expect(await customToken.totalSupply()).to.equal(initialSupply);
  });
});
