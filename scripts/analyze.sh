#!/bin/sh

rm -rf reports
mkdir -p reports/storage

npm run flatten

alias myth="docker run -i --rm -v $(pwd):/metadium -v /tmp/myth/solc-v0.4.24:/root/.py-solc/solc-v0.4.24 -w \"/metadium/\" mythril/myth:latest --solv 0.4.24 "
alias oyente="docker run -it --rm -v $(pwd):/metadium  moyente python oyente.py "
echo "Analyzing contracts with Mythril..."
# example
# docker run  -i --rm -v $(pwd):/metadium -v /tmp/myth/solc-v0.4.24:/root/.py-solc/solc-v0.4.24 -w "/metadium/" mythril/myth:latest --solv 0.4.24 -x flat/{sol File} -o markdown >> reports/{output file}

# docker run -i --rm -v $(pwd):/metadium -v /tmp/myth/solc-v0.4.24:/root/.py-solc/solc-v0.4.24 -w "/metadium/" mythril/myth:latest --solv 0.4.24 -x flat/storage/EnvStorage.sol -o markdown >> reports/storage/EnvStorage_Mythrill.md
# docker run -i --rm -v $(pwd):/metadium -v /tmp/myth/solc-v0.4.24:/root/.py-solc/solc-v0.4.24 -w "/metadium/" mythril/myth:latest --solv 0.4.24 -x flat/storage/EnvStorageImp.sol -o markdown >> reports/storage/EnvStorageImp_Mythrill.md
# docker run -i --rm -v $(pwd):/metadium -v /tmp/myth/solc-v0.4.24:/root/.py-solc/solc-v0.4.24 -w "/metadium/" mythril/myth:latest --solv 0.4.24 -x flat/storage/BallotStorage.sol -o markdown >> reports/storage/BallotStorageImp_Mythrill.md
myth -x flat/storage/EnvStorage.sol -o markdown >> reports/storage/EnvStorage_Mythrill.md
myth -x flat/storage/EnvStorageImp.sol -o markdown >> reports/storage/EnvStorageImp_Mythrill.md
myth -x flat/storage/BallotStorage.sol -o markdown >> reports/storage/BallotStorage_Mythrill.md
myth -x flat/Staking.sol -o markdown >> reports/Staking_Mythrill.md
myth -x flat/Gov.sol -o markdown >> reports/Gov_Mythrill.md
myth -x flat/GovImp.sol -o markdown >> reports/GovImp_Mythrill.md
myth -x flat/Registry.sol -o markdown >> reports/Registry_Mythrill.md
echo "Analyzing contracts with Oyente..."
# example
# docker run -it --rm -v $(pwd):/metadium  moyente python oyente.py -ce -s /metadium/flat/{sol File} >> reports/{output file}

# docker run -it --rm -v $(pwd):/metadium  moyente python oyente.py -ce -s /metadium/flat/storage/EnvStorage.sol >> reports/storage/EnvStorage_Oyente.log
# docker run -it --rm -v $(pwd):/metadium  moyente python oyente.py -ce -s /metadium/flat/storage/EnvStorageImp.sol >> reports/storage/EnvStorageImp_Oyente.log
# docker run -it --rm -v $(pwd):/metadium  moyente python oyente.py -ce -s /metadium/flat/storage/BallotStorageImp.sol >> reports/storage/BallotStorageImp_Oyente.log
oyente -ce -s /metadium/flat/storage/EnvStorage.sol >> reports/storage/EnvStorage_Oyente.log
oyente -ce -s /metadium/flat/storage/EnvStorageImp.sol >> reports/storage/EnvStorageImp_Oyente.log
oyente -ce -s /metadium/flat/storage/BallotStorageImp.sol >> reports/storage/BallotStorageImp_Oyente.log
oyente -ce -s /metadium/flat/Staking.sol >> reports/Staking_Oyente.log
oyente -ce -s /metadium/flat/Gov.sol >> reports/Gov_Oyente.log
oyente -ce -s /metadium/flat/GovImp.sol >> reports/GovImp_Oyente.log
oyente -ce -s /metadium/flat/Registry.sol >> reports/Registry_Oyente.log
