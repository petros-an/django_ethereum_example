let Oracle = artifacts.require('./Oracle.sol')

module.exports = function(deployer, network, addresses) {

  deployer.deploy(Oracle);
};

