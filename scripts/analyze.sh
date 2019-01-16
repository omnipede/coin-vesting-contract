#!/bin/sh

rm -rf reports
mkdir -p reports

npm run flatten

echo "Analyzing contracts with Mythril..."
# example
# docker run  -i --rm -v $(pwd):/metadium -v /tmp/myth/solc-v0.4.24:/root/.py-solc/solc-v0.4.24 -w "/metadium/" mythril/myth:latest --solv 0.4.24 -x flat/{sol File} -o markdown >> reports/{output file}
#docker run -i --rm -v $(pwd):/metadium -v /tmp/myth/solc-v0.4.24:/root/.py-solc/solc-v0.4.24 -w "/metadium/" mythril/myth:latest --solv 0.4.24 -x flat/AdminAnchor.sol -o markdown >> reports/AdminAnchor_Mythrill.md
docker run -i --rm -v $(pwd):/metadium -v /tmp/myth/solc-v0.4.24:/root/.py-solc/solc-v0.4.24 -w "/metadium/" mythril/myth:latest --solv 0.4.24 -x flat/Funding.sol -o markdown >> reports/Funding_Mythrill.md

echo "Analyzing contracts with Oyente..."
# example
# docker run -it --rm -v $(pwd):/metadium  moyente python oyente.py -ce -s /metadium/flat/{sol File} >> reports/{output file}
#docker run -it --rm -v $(pwd):/metadium  moyente python oyente.py -ce -s /metadium/flat/AdminAnchor.sol >> reports/AdminAnchor_Oyente.log
docker run -it --rm -v $(pwd):/metadium  moyente python oyente.py -ce -s /metadium/flat/Funding.sol >> reports/Funding_Oyente.log