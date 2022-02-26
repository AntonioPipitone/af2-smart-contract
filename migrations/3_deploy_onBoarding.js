const User = artifacts.require("User");
const OnBoarding = artifacts.require("OnBoarding");

module.exports =async function (deployer) {
  await deployer.deploy(OnBoarding, User.address);
};