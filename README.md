# governance-contract
Governance contract

### Requirements
Truffle v4.1.14
solc v 0.4.24
nodejs v 8.9.3

### Preequiste

1. Docker
   
   Install at https://docs.docker.com/install

2. Install solc 0.4.24
``` 
    $ docker pull ethereum/solc:0.4.24
    $ cp dockers/solc /usr/local/bin/solc
```

### Install 

#### to install libraries
```
$ npm install 
```

#### to install analyzer 
```
$ npm run install_analyzer
```

### Run

#### to compile Solidity Codes 
```
$ npm run compile
```
#### to run test
```
$ npm run test
```
#### to run code coverage 
```
$ npm run coverage
```
#### To flatten a Solidity files
```
$ npm run flatten
```