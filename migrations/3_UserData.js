const userData= artifacts.require("UserData");

module.exports = function (deployer) {
  deployer.deploy(userData);
};
 
