#!/bin/bash
chmod +x values.sh
source values.sh

git clone $EPI_WORKSPACE tmp/epi
cd tmp/epi

if [[ "$1" == "dev" ]]; then
  echo "npm run dev-install"
  npm run dev-install
else
  echo "npm install"
  npm install
fi

node ./node_modules/octopus/scripts/setEnv --file=../../../env.json "node ./bin/octopusRun.js postinstall"
cd ../../
printenv
echo "$BUILDER_REPO_NAME"
DOCKER_BUILDKIT=1 docker build --no-cache -t $BUILDER_REPO_NAME --build-arg BASE_IMAGE=$NODE_ALPINE_BASE_IMAGE . -f builder-dockerfile  --network host
DOCKER_BUILDKIT=1 docker build --no-cache -t $RUNNER_REPO_NAME --build-arg BASE_IMAGE=$NODE_ALPINE_BASE_IMAGE . -f runner-dockerfile  --network host

rm -rf tmp
