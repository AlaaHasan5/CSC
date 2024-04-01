const CentralAuthority = artifacts.require("CentralAuthority");

module.exports = function (deployer) {
    deployer.deploy(CentralAuthority);
};