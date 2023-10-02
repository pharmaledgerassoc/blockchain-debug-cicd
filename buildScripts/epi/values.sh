#!/bin/bash
echo "Setting variables ..."
NODE_ALPINE_BASE_IMAGE='node:18.15.0-alpine'
NODE_BASE_IMAGE='node:18.15.0'
HUB_IDENTIFIER='docker.io'
EPI_WORKSPACE='http://github.com/pharmaledgerassoc/epi-workspace'
BUILDER_NAME='epi-builder'
BUILDER_REPO_NAME='pharmaledger/epi-builder'
if [[ -z "$VERSION" ]]; then
  VERSION='1.5.4'
fi
RUNNER_NAME='epi-runner'
RUNNER_REPO_NAME='pharmaledger/epi-runner'
