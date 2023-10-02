#!/bin/bash

ACTION="${1}"

AWS_ACCOUNT_ID="${2}"

NETWORK_NAME="${3}"
CLUSTER_NAME="${4}"

export GH_TOKEN="${5}"

GIT_USERNAME="${6}"
GIT_EMAIL="${7}"

DNS_NAME="${8}"
DOMAIN="${9}"
SUB_DOMAIN="${10}"
VAULT_DOMAIN="${11}"

ETH_ADAPTER_HELM_CHART_VERSION="${12}"

ETHADAPTER_IMAGE_REPOSITORY="${13}"
ETHADAPTER_RUNNER_IMAGE_VERSION="${14}"
ETHADAPTER_RUNNER_IMAGE_VERSION_SHA="${15}"

EPI_HELM_CHART_VERSION="${16}"

EPI_RUNNER_IMAGE_REPOSITORY="${17}"
EPI_RUNNER_IMAGE_VERSION="${18}"
EPI_RUNNER_IMAGE_VERSION_SHA="${19}"

EPI_BUILDER_IMAGE_REPOSITORY="${20}"
EPI_BUILDER_IMAGE_VERSION="${21}"
EPI_BUILDER_IMAGE_VERSION_SHA="${22}"

BUILD_SECRET_KEY="${23}"
SSO_SECRETS_ENCRYPTION_KEY="${24}"

OAUTH_JWKS_ENDPOINT="${25}"
ISSUER="${26}"
AUTHORIZATION_ENDPOINT="${27}"
TOKEN_ENDPOINT="${28}"

LOGOUT_URL="${29}"

CLIENT_ID="${30}"
CLIENT_SECRET="${31}"

DEPLOYMENT_NAME="6-epi-app-deployment-pla"

KUBE_CONFIG_PATH="~/.kube/config"

BACKEND_CONFIG_DIRECTORY_PATH="../../../../private/${NETWORK_NAME}/${CLUSTER_NAME}"
NETWORKS_CONFIG_DIRECTORY_PATH="../../../../networks"

AWS_REGION="$(cat ${BACKEND_CONFIG_DIRECTORY_PATH}/region)"

git config --global user.name $GIT_USERNAME
git config --global user.email $GIT_EMAIL
git config --global pull.ff true

mkdir -p ${BACKEND_CONFIG_DIRECTORY_PATH}/terraform/${DEPLOYMENT_NAME}

cat <<EOF > terraform.tfvars
network_name = "${NETWORK_NAME}"
cluster_name = "${CLUSTER_NAME}"
env_dir_path = "${BACKEND_CONFIG_DIRECTORY_PATH}"
kube_config_path = "${KUBE_CONFIG_PATH}"
github_read_write_token = "${GH_TOKEN}"
dns_name = "${DNS_NAME}"
domain = "${DOMAIN}" 
sub_domain = "${SUB_DOMAIN}" 
vault_domain = "${VAULT_DOMAIN}"

ethadapter_image_repository = "${ETHADAPTER_IMAGE_REPOSITORY}"  
ethadapter_image_version = "${ETHADAPTER_IMAGE_VERSION}" 
ethadapter_image_version_sha = "${ETHADAPTER_IMAGE_VERSION_SHA}"

epi_runner_image_repository = "${EPI_RUNNER_IMAGE_REPOSITORY}"  
epi_runner_image_version = "${EPI_RUNNER_IMAGE_VERSION}" 
epi_runner_image_version_sha = "${EPI_RUNNER_IMAGE_VERSION_SHA}"

epi_builder_image_repository = "${EPI_BUILDER_IMAGE_REPOSITORY}" 
epi_builder_image_version = "${EPI_BUILDER_IMAGE_VERSION}" 
epi_builder_image_version_sha = "${EPI_BUILDER_IMAGE_VERSION_SHA}" 

build_secret_key = "${BUILD_SECRET_KEY}" 
sso_secrets_encryption_key = "${SSO_SECRETS_ENCRYPTION_KEY}" 
oauth_jwks_endpoint = "${OAUTH_JWKS_ENDPOINT}" 
issuer = "${ISSUER}" 
authorization_endpoint = "${AUTHORIZATION_ENDPOINT}" 
token_endpoint = "${TOKEN_ENDPOINT}" 
logout_url = "${LOGOUT_URL}" 
client_id = "${CLIENT_ID}" 
client_secret = "${CLIENT_SECRET}" 
ethadapter_helm_chart_version = "${ETH_ADAPTER_HELM_CHART_VERSION}" 
epi_helm_chart_version = "${EPI_HELM_CHART_VERSION}"
EOF

terraform init -reconfigure \
  -backend-config="bucket=tf-state-${AWS_REGION}-${AWS_ACCOUNT_ID}" \
  -backend-config="key=${NETWORK_NAME}/${CLUSTER_NAME}/${DEPLOYMENT_NAME}/terraform.tfstate" \
  -backend-config="region=${AWS_REGION}" \
  -backend-config="encrypt=true" \
  -backend-config="dynamodb_table=tf-state-${AWS_REGION}-${AWS_ACCOUNT_ID}"

aws eks update-kubeconfig --region $AWS_REGION --name "${NETWORK_NAME}-${CLUSTER_NAME}"

if [[ $ACTION == "destroy" ]] && [[ -f ${BACKEND_CONFIG_DIRECTORY_PATH}/terraform/${DEPLOYMENT_NAME}/terraform.tfvars ]];
then
  mv ${BACKEND_CONFIG_DIRECTORY_PATH}/terraform/${DEPLOYMENT_NAME}/terraform.tfvars terraform.tfvars
fi

terraform $ACTION --auto-approve

TERRAFORM_RUN_EXIT_CODE=$(echo $?)

mv terraform.tfvars ${BACKEND_CONFIG_DIRECTORY_PATH}/terraform/${DEPLOYMENT_NAME}/terraform.tfvars
terraform state pull > ${BACKEND_CONFIG_DIRECTORY_PATH}/terraform/${DEPLOYMENT_NAME}/terraform.tfstate

exit $TERRAFORM_RUN_EXIT_CODE
