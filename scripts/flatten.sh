#!/bin/sh

rm -rf flat
mkdir -p flat/storage


alias flatten="solidity_flattener --solc-paths=\"openzeppelin-solidity=/metadium/node_modules/openzeppelin-solidity ../=/metadium/contracts/\""
echo "flatten Registry.sol"
flatten contracts/Registry.sol --output flat/Registry.sol
echo "flatten Gov.sol"
flatten contracts/Gov.sol --output flat/Gov.sol
echo "flatten GovImp.sol"
flatten contracts/GovImp.sol --output flat/GovImp.sol
echo "flatten Staking.sol"
flatten contracts/Staking.sol --output flat/Staking.sol
echo "flatten storage/BallotStorage.sol"
flatten contracts/storage/BallotStorage.sol --output flat/storage/BallotStorage.sol
echo "flatten storage/EnvStorage.sol"
flatten contracts/storage/EnvStorage.sol --output flat/storage/EnvStorage.sol
echo "flatten storage/EnvStorageImp.sol"
flatten contracts/storage/EnvStorageImp.sol --output flat/storage/EnvStorageImp.sol
