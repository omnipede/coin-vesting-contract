'use strict'

const Registry = artifacts.require('Registry.sol')
const Staking = artifacts.require('Staking.sol')
const BallotStorage = artifacts.require('BallotStorage.sol')
const EnvStorage = artifacts.require('EnvStorage.sol');
const EnvStorageImp = artifacts.require('EnvStorageImp.sol');
const GovImp = artifacts.require('GovImp.sol')
const Gov = artifacts.require('Gov.sol')

const fs = require('fs')
const Web3 = require('web3')

// config file
const config = require('config')
//const ropstenConfig = config.get('ropsten')
const metaTestnetConfig = config.get('metadiumTestnet')

// eslint-disable-next-line max-len
const enode = '0x6f8a80d14311c39f35f516fa664deaaaa13e85b2f7493f37f6144d86991ec012937307647bd3b9a82abe2974e1407241d54947bbb39763a4cac9f77166ad92a0';
const ip = '127.0.0.1';
const port = 8542;
const memo = 'memo';

const web3 = new Web3(new Web3.providers.HttpProvider(metaTestnetConfig.provider));
const amount = web3.utils.toWei('1', 'ether')

//TODO deploy script clean up
async function deploy(deployer, network, accounts) {

    
    let registry, govImp, gov, staking, ballotStorage, envStorageImp, envStorage
    deployer.then(async () => {
        // Deploy contracts
        [registry, staking, ballotStorage, govImp, gov, envStorageImp, envStorage] = await deployContracts(deployer, network, accounts)

        // Setup contracts
        await basicRegistrySetup(registry, staking, ballotStorage, envStorage, gov)

        // Initialize staking contract
        console.log('Initialize staking')
        await staking.deposit({ value: amount, from: accounts[0].toString() })

        // Initialize gov contract
        console.log('Initialize governance')
        await gov.init(registry.address, govImp.address, amount, enode, ip, port)

        // Write contract address to contract.json
        await writeToContractsJson(registry, staking, ballotStorage, envStorage, gov)
    })
}

async function deployContracts(deployer, network, accounts) {
    //proxy create metaID instead user for now. Because users do not have enough fee.
    let registry, staking, ballotStorage, govImp, gov, envStorageImp, envStorage

    registry = await deployer.deploy(Registry)
    staking = await deployer.deploy(Staking, registry.address)
    ballotStorage = await deployer.deploy(BallotStorage, registry.address)
    envStorageImp = await deployer.deploy(EnvStorageImp)
    envStorage = await deployer.deploy(EnvStorage, registry.address, envStorageImp.address)
    govImp = await deployer.deploy(GovImp)
    gov = await deployer.deploy(Gov)

    return [registry, staking, ballotStorage, govImp, gov, envStorageImp, envStorage]
}

async function basicRegistrySetup(registry, staking, ballotStorage, envStorage, gov) {
    await registry.setContractDomain("Staking", staking.address)
    await registry.setContractDomain("BallotStorage", ballotStorage.address)
    await registry.setContractDomain("EnvStorage", envStorage.address)
    await registry.setContractDomain("GovernanceContract", gov.address)
}

async function writeToContractsJson(registry, staking, ballotStorage, envStorage, gov) {
    console.log(`Writing Contract Address To contracts.json`)

    let contractData = {}
    contractData["REGISTRY_ADDRESS"] = registry.address
    contractData["STAKING_ADDRESS"] = staking.address
    contractData["ENV_STORAGE_ADDRESS"] = envStorage.address
    contractData["BALLOT_STORAGE_ADDRESS"] = ballotStorage.address
    contractData["GOV_ADDRESS"] = gov.address

    fs.writeFile('contracts.json', JSON.stringify(contractData), 'utf-8', function (e) {
        if (e) {
            console.log(e);
        } else {
            console.log('contracts.json updated!');
        }
    });
}

module.exports = deploy