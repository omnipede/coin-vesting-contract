#!/bin/sh

rm -rf flat
mkdir -p flat

alias flatten="solidity_flattener --solc-paths=\"../=/metadium/contracts/\""

flatten contracts/AdminAnchor.sol --output flat/AdminAnchor.sol

