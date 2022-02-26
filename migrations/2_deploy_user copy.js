const User = artifacts.require("User");

module.exports =async function (deployer) {
  await deployer.deploy(User);
};