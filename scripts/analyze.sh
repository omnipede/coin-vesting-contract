#!/bin/sh

rm -rf reports
mkdir -p reports

npm run flatten

echo "Analyzing contracts with Mythril..."
# example
# docker run -v $(pwd):/metadium -v /tmp/myth/solc-v0.4.24:/root/.py-solc/solc-v0.4.24 -w "/metadium/" mythril/myth:latest --solv 0.4.24 -x flat/{sol File} -o markdown >> reports/{output file}
docker run -v $(pwd):/metadium -v /tmp/myth/solc-v0.4.24:/root/.py-solc/solc-v0.4.24 -w "/metadium/" mythril/myth:latest --solv 0.4.24 -x flat/AdminAnchor.sol -o markdown >> reports/AdminAnchor_Mythrill.md
docker run -v $(pwd):/metadium -v /tmp/myth/solc-v0.4.24:/root/.py-solc/solc-v0.4.24 -w "/metadium/" mythril/myth:latest --solv 0.4.24 -x flat/Ballot.sol -o markdown >> reports/Ballot_Mythrill.md

echo "Analyzing contracts with Oyente..."
# example
# docker run -i -t -v $(pwd):/metadium  moyente python oyente.py -ce -s /metadium/flat/{sol File} >> reports/{output file}
docker run -i -t -v $(pwd):/metadium  moyente python oyente.py -ce -s /metadium/flat/AdminAnchor.sol >> reports/AdminAnchor_Oyente.log
docker run -i -t -v $(pwd):/metadium  moyente python oyente.py -ce -s /metadium/flat/Ballot.sol >> reports/Ballot_Oyente.log