#!/bin/sh

rm -rf reports
mkdir -p reports

npm run flatten

echo "Analyzing contracts with Mythril..."

#myth -x flat_contracts/AdminAnchor.sol -o markdown >> reports/AdminAnchor_Mythrill.md
#docker run -v $(pwd):/metadium -w "/metadium/" mythril/myth:latest --solv 0.4.24 -x flat/AdminAnchor.sol >> reports/AdminAnchor_Mythrill.md
docker run -v $(pwd):/metadium -v /tmp/myth/solc-v0.4.24:/root/.py-solc/solc-v0.4.24 -w "/metadium/" mythril/myth:latest --solv 0.4.24 -x flat/AdminAnchor.sol

docker run -i -t -v $(pwd):/metadium  toyente python oyente.py -ce -s /metadium/flat/AdminAnchor.sol >> reports/AdminAnchor_Oyente.log
