require('babel-register')

var HDWalletProvider = require("truffle-hdwallet-provider")

const config = require('config')
const ropstenConfig = config.get('ropsten')
const metaTestnetConfig = config.get('metadiumTestnet')

module.exports = {
  networks: {
    development: {
      host: "localhost",
      port: 8545,
      network_id: "*", // Match any network id
      gas: 10000000
    },
    metadiumTestnet: {
        provider: () => {
          return new HDWalletProvider(metaTestnetConfig.mnemonic, metaTestnetConfig.provider);
        },
        network_id: metaTestnetConfig.network_id,
        gasPrice: metaTestnetConfig.gasPrice
    },
    ropsten: {
        provider: function() {
          return new HDWalletProvider(ropstenConfig.mnemonic, ropstenConfig.provider)
        },
        network_id: ropstenConfig.network_id,
        gas: ropstenConfig.gas,
        gasPrice: ropstenConfig.gasPrice
    }
  },
  solc: {
    optimizer: {
      enabled: true,
      runs: 200
    },
    
  },
  mocha: {
    reporter: 'eth-gas-reporter',
    reporterOptions: {
      currency: 'USD',
      gasPrice: 21
    }
  }

  // See <http://truffleframework.com/docs/advanced/configuration>
  // to customize your Truffle configuration!
}
