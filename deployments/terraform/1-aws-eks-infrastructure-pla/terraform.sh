#!/bin/bash

ACTION="${1}"

AWS_REGION="${2}"
AWS_ACCOUNT_ID="${3}"

NETWORK_NAME="${4}"

CLUSTER_NAME="${5}"
CLUSTER_VERSION="${6}"

export GH_TOKEN="${7}"

GIT_USERNAME="${8}"
GIT_EMAIL="${9}"

EKS_AUTH_USERS="${10}"
EKS_AUTH_ROLES="${11}"
EKS_AUTH_ACCOUNTS="${12}"

DEPLOYMENT_NAME="1-aws-eks-infrastructure-pla"

KUBE_CONFIG_PATH="~/.kube/config"

BACKEND_CONFIG_DIRECTORY_PATH="../private/${NETWORK_NAME}/${CLUSTER_NAME}"

git config --global user.name $GIT_USERNAME
git config --global user.email $GIT_EMAIL
git config --global pull.ff true

mkdir -p ${BACKEND_CONFIG_DIRECTORY_PATH}/terraform/${DEPLOYMENT_NAME}

cat <<EOF > terraform.tfvars
aws_region = "${AWS_REGION}"
network_name = "${NETWORK_NAME}"
cluster_name = "${CLUSTER_NAME}"
cluster_version = "${CLUSTER_VERSION}"
kube_config_path = "${KUBE_CONFIG_PATH}"
backend_config_directory_path = "${BACKEND_CONFIG_DIRECTORY_PATH}"
eks_auth_users = $EKS_AUTH_USERS
eks_auth_roles = $EKS_AUTH_ROLES
eks_auth_accounts = $EKS_AUTH_ACCOUNTS
EOF

terraform init -reconfigure \
  -backend-config="bucket=tf-state-${AWS_REGION}-${AWS_ACCOUNT_ID}" \
  -backend-config="key=${NETWORK_NAME}/${CLUSTER_NAME}/${DEPLOYMENT_NAME}/terraform.tfstate" \
  -backend-config="region=${AWS_REGION}" \
  -backend-config="encrypt=true" \
  -backend-config="dynamodb_table=tf-state-${AWS_REGION}-${AWS_ACCOUNT_ID}"

aws eks update-kubeconfig --region $AWS_REGION --name "${NETWORK_NAME}-${CLUSTER_NAME}"

if [[ $ACTION == "destroy" ]] && [[ -f ${BACKEND_CONFIG_DIRECTORY_PATH}/terraform/terraform.tfvars ]];
then
  mv ${BACKEND_CONFIG_DIRECTORY_PATH}/terraform/terraform.tfvars terraform.tfvars

  rm -f ${BACKEND_CONFIG_DIRECTORY_PATH}/region
fi

terraform $ACTION --auto-approve

aws eks update-kubeconfig --region $AWS_REGION --name "${NETWORK_NAME}-${CLUSTER_NAME}"

terraform $ACTION --auto-approve

TERRAFORM_RUN_EXIT_CODE=$(echo $?)

mv terraform.tfvars ${BACKEND_CONFIG_DIRECTORY_PATH}/terraform/${DEPLOYMENT_NAME}/terraform.tfvars
terraform state pull > ${BACKEND_CONFIG_DIRECTORY_PATH}/terraform/${DEPLOYMENT_NAME}/terraform.tfstate

exit $TERRAFORM_RUN_EXIT_CODE
