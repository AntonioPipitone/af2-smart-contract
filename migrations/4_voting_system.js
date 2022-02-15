const VotingSystem = artifacts.require("designVoting1");

module.exports = function (deployer) {
  deployer.deploy(VotingSystem);
};
