const Link = artifacts.require("Link");
const Wallet = artifacts.require("Wallet");
module.exports = async function (deployer) {
  await deployer.deploy(Link);
  

};
