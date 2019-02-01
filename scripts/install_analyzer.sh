#!/bin/sh
mkdir -p /tmp/myth/solc-v0.4.24
docker pull mythril/myth:latest
cd dockers
docker build -t moyente . -f ./Dockerfile_moyente