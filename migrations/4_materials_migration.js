const Materials = artifacts.require("Materials");

module.exports = function (deployer) {
    deployer.deploy(Materials);
};