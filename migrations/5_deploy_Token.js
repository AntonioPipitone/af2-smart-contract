const TestToken = artifacts.require("TestToken");
const AntoTokenSale = artifacts.require("AntoTokenSale");
const VotingSystem = artifacts.require("VotingSystem")

const web3 = require('web3');

module.exports = async function(deployer) {
  await deployer.deploy(TestToken);
  const tokenPrice = web3.utils.toWei('0.001','ether') // 0.001 eth
  let SaleContract = await deployer.deploy(AntoTokenSale, TestToken.address, tokenPrice);
  let TestTokenContract = await TestToken.deployed();

  TestTokenContract.transfer(SaleContract.address, web3.utils.toWei('750000', 'ether'));
  TestTokenContract.approve(SaleContract.address, VotingSystem.address, web3.utils.toWei('750000', 'ether'));

};
