chmod +x values.sh
source values.sh

git clone $EPI_WORKSPACE tmp/epi
cd tmp/epi

if [ "$1" == "dev" ]; then
  echo "npm run dev-install"
  npm run dev-install
else
  echo "npm install"
  npm install
fi

node ./node_modules/octopus/scripts/setEnv --file=../../../env.json "node ./bin/octopusRun.js postinstall"

cd ./ethadapter/EthAdapter
npm install --unsafe-perm --production

cd ../../../../
. values.sh

docker build --no-cache -t $ETH_ADAPTER_REPO_NAME --build-arg NODE_ALPINE_BASE_IMAGE=$NODE_ALPINE_BASE_IMAGE --build-arg NODE_BASE_IMAGE=$NODE_BASE_IMAGE . -f Dockerfile --network host
#rm -rf tmp
