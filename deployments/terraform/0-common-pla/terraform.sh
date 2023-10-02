#!/bin/bash

ACTION="${1}"

AWS_REGION="${2}"

export GH_TOKEN="${3}"

GIT_USERNAME="${4}"
GIT_EMAIL="${5}"

DEPLOYMENT_NAME="0-common-pla"

BACKEND_CONFIG_DIRECTORY_PATH="../../../../private/${DEPLOYMENT_NAME}"

git config --global user.name $GIT_USERNAME
git config --global user.email $GIT_EMAIL
git config --global pull.ff true

terraform init -reconfigure \
  -backend-config="path=${BACKEND_CONFIG_DIRECTORY_PATH}/terraform/terraform.tfstate"

terraform $ACTION --auto-approve \
  -var aws_region="${AWS_REGION}"

TERRAFORM_RUN_EXIT_CODE=$(echo $?)

cd $BACKEND_CONFIG_DIRECTORY_PATH
git add -A
git commit -m "Managed by Terraform - ./private/${DEPLOYMENT_NAME}"

git pull origin master
git push origin master

exit $TERRAFORM_RUN_EXIT_CODE
