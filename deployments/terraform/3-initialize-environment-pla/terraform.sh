#!/bin/bash

ACTION="${1}"
NETWORK_NAME="${2}"
CLUSTER_NAME="${3}"

export GH_TOKEN="${4}"

GIT_USERNAME="${5}"
GIT_EMAIL="${6}"
GIT_REPOSITORY_NAME="${7}"

QUORUM_NODE_HELM_CHART_VERSION="${8}"

DEPLOYMENT_NAME="3-initialize-environment"

BACKEND_CONFIG_DIRECTORY_PATH="../../../../private"
TMP_CONFIG_DIRECTORY_PATH="../../../../tmp"
NETWORKS_CONFIG_DIRECTORY_PATH="../../../../networks"

git config --global user.name $GIT_USERNAME
git config --global user.email $GIT_EMAIL
git config --global pull.ff true

AWS_REGION="$(cat ${BACKEND_CONFIG_DIRECTORY_PATH}/${NETWORK_NAME}/${CLUSTER_NAME}/region)"

aws eks update-kubeconfig --region $AWS_REGION --name "${NETWORK_NAME}-${CLUSTER_NAME}"

terraform init -reconfigure \
  -backend-config="path=${BACKEND_CONFIG_DIRECTORY_PATH}/${NETWORK_NAME}/${CLUSTER_NAME}/terraform/${DEPLOYMENT_NAME}/terraform.tfstate"

terraform $ACTION --auto-approve \
  -var aws_region="${AWS_REGION}" \
  -var network_name="${NETWORK_NAME}" \
  -var cluster_name="${CLUSTER_NAME}" \
  -var env_dir_path="${BACKEND_CONFIG_DIRECTORY_PATH}/${NETWORK_NAME}/${CLUSTER_NAME}" \
  -var net_dir_path="${NETWORKS_CONFIG_DIRECTORY_PATH}/${NETWORK_NAME}" \
  -var github_repository_name="${GIT_REPOSITORY_NAME}" \
  -var github_read_write_token="${GH_TOKEN}" \
  -var helm_chart_version="${QUORUM_NODE_HELM_CHART_VERSION}"

TERRAFORM_RUN_EXIT_CODE=$(echo $?)

if [[ $ACTION == "destroy" ]]; then
  rm -rf "${BACKEND_CONFIG_DIRECTORY_PATH}/${NETWORK_NAME}/${CLUSTER_NAME}/tmp"
fi

if [[ -d $NETWORKS_CONFIG_DIRECTORY_PATH ]]; then
  cd $NETWORKS_CONFIG_DIRECTORY_PATH

  git add -- "./${NETWORK_NAME}"
  git commit -m "Managed by Terraform - ./networks/${NETWORK_NAME}/${CLUSTER_NAME}"

  cd ../private
else
  cd $BACKEND_CONFIG_DIRECTORY_PATH
fi

git add -- "./${NETWORK_NAME}/${CLUSTER_NAME}"
git commit -m "Managed by Terraform - ./private/${NETWORK_NAME}/${CLUSTER_NAME}"

git pull origin master
git push origin master

exit $TERRAFORM_RUN_EXIT_CODE
