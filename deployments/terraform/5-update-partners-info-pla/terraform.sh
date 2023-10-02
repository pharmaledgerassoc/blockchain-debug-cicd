#!/bin/bash

ACTION="${1}"
NETWORK_NAME="${2}"
CLUSTER_NAME="${3}"

export GH_TOKEN="${4}"

GIT_USERNAME="${5}"
GIT_EMAIL="${6}"

DEPLOYMENT_NAME="5-update-partners-info-pla"

KUBE_CONFIG_PATH="~/.kube/config"

BACKEND_CONFIG_DIRECTORY_PATH="../../../../private"
NETWORKS_CONFIG_DIRECTORY_PATH="../../../../networks"

git config --global user.name $GIT_USERNAME
git config --global user.email $GIT_EMAIL
git config --global pull.ff true

AWS_REGION="$(cat ${BACKEND_CONFIG_DIRECTORY_PATH}/${NETWORK_NAME}/${CLUSTER_NAME}/region)"

aws eks update-kubeconfig --region $AWS_REGION --name "${NETWORK_NAME}-${CLUSTER_NAME}"

terraform init -reconfigure \
  -backend-config="path=${BACKEND_CONFIG_DIRECTORY_PATH}/${NETWORK_NAME}/${CLUSTER_NAME}/terraform/${DEPLOYMENT_NAME}/terraform.tfstate"

terraform $ACTION --auto-approve \
  -var cluster_name="${CLUSTER_NAME}" \
  -var env_dir_path="${BACKEND_CONFIG_DIRECTORY_PATH}/${NETWORK_NAME}/${CLUSTER_NAME}" \
  -var net_dir_path="${NETWORKS_CONFIG_DIRECTORY_PATH}/${NETWORK_NAME}" \
  -var kube_config_path="${KUBE_CONFIG_PATH}" \
  -var github_read_write_token="${GH_TOKEN}"

TERRAFORM_RUN_EXIT_CODE=$(echo $?)

cd $BACKEND_CONFIG_DIRECTORY_PATH
git add -- "./${NETWORK_NAME}/${CLUSTER_NAME}"
git commit -m "Managed by Terraform - ./private/${NETWORK_NAME}/${CLUSTER_NAME}"

git pull origin master
git push origin master

exit $TERRAFORM_RUN_EXIT_CODE
