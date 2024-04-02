const CentralAuthority = artifacts.require("CentralAuthority");
const CreateTender = artifacts.require("CreateTender");
const Bidding = artifacts.require("Bidding");
const Materials = artifacts.require("Materials");


module.exports = function(deployer) {
  let CentralAuthorityInstance;
  let CreateTenderInstance;
  let BiddingInstance;

  // Deploy the first contract
  deployer.deploy(CentralAuthority)
  .then(() => {
    // Get the deployed instance of the first contract
    return CentralAuthority.deployed();
  })
  .then((instance) => {
    CentralAuthorityInstance = instance;
    // Deploy the second contract and pass the address of the first contract
    return deployer.deploy(CreateTender, CentralAuthorityInstance.address);
  })
  .then(() => {
    // Get the deployed instance of the second contract
    return CreateTender.deployed();
  })
  .then((instance) => {
    CreateTenderInstance = instance;
    // Deploy the third contract and pass the addresses of the first and second contracts
    return deployer.deploy(Bidding, CentralAuthorityInstance.address, CreateTenderInstance.address);
  })
  .then(() => {
    // Get the deployed instance of the third contract
    return Bidding.deployed();
  })
  .then((instance) => {
    BiddingInstance = instance;
    // Deploy the fourth contract and pass the addresses of the first, second, and third contracts
    return deployer.deploy(Materials, CentralAuthorityInstance.address, CreateTenderInstance.address, BiddingInstance.address);
  });
};
