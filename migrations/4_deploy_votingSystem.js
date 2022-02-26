const User = artifacts.require("User");
const VotingSystem = artifacts.require("VotingSystem");

module.exports = function (deployer) {
  deployer.deploy(VotingSystem, User.address);
};
