#!/bin/bash

ACTION="${1}"

AWS_ACCOUNT_ID="${2}"

NETWORK_NAME="${3}"
CLUSTER_NAME="${4}"

export GH_TOKEN="${5}"

GIT_USERNAME="${6}"
GIT_EMAIL="${7}"

VPC_CNI_VERSION="${8}"
KUBE_PROXY_VERSION="${9}"
COREDNS_VERSION="${10}"
FLUENT_BIT_HELM_CHART_VERSION="${11}"
FLUENT_BIT_IMAGE_VERSION="${12}"
AWS_LOAD_BALANCER_HELM_CHART_VERSION="${13}"
AWS_LOAD_BALANCER_IMAGE_VERSION="${14}"
AWS_CSI_SECRETS_STORE_PROVIDER_HELM_CHART_VERSION="${15}"
AWS_CSI_SECRETS_STORE_PROVIDER_IMAGE_VERSION="${16}"
EBS_CSI_DRIVER_VERSION="${17}"
CSI_EXTERNAL_SNAPSHOTTER_IMAGE_VERSION="${18}"
SNAPSCHEDULER_HELM_CHART_VERSION="${19}"

DEPLOYMENT_NAME="2-aws-eks-bootstrap-pla"

KUBE_CONFIG_PATH="~/.kube/config"

BACKEND_CONFIG_DIRECTORY_PATH="../private/${NETWORK_NAME}/${CLUSTER_NAME}"

AWS_REGION="$(cat ${BACKEND_CONFIG_DIRECTORY_PATH}/region)"

git config --global user.name $GIT_USERNAME
git config --global user.email $GIT_EMAIL
git config --global pull.ff true

mkdir -p ${BACKEND_CONFIG_DIRECTORY_PATH}/terraform/${DEPLOYMENT_NAME}

cat <<EOF > terraform.tfvars
aws_region = "${AWS_REGION}"
network_name = "${NETWORK_NAME}"
cluster_name = "${CLUSTER_NAME}"
kube_config_path = "${KUBE_CONFIG_PATH}"
vpc_cni_version = "${VPC_CNI_VERSION}"
kube_proxy_version = "${KUBE_PROXY_VERSION}"
coredns_version = "${COREDNS_VERSION}"
fluent_bit_helm_chart_version = "${FLUENT_BIT_HELM_CHART_VERSION}"
fluent_bit_image_version = "${FLUENT_BIT_IMAGE_VERSION}"
aws_load_balancer_helm_chart_version = "${AWS_LOAD_BALANCER_HELM_CHART_VERSION}"
aws_load_balancer_image_version = "${AWS_LOAD_BALANCER_IMAGE_VERSION}"
aws_csi_secrets_store_provider_helm_chart_version = "${AWS_CSI_SECRETS_STORE_PROVIDER_HELM_CHART_VERSION}"
aws_csi_secrets_store_provider_image_version = "${AWS_CSI_SECRETS_STORE_PROVIDER_IMAGE_VERSION}"
ebs_csi_driver_version = "${EBS_CSI_DRIVER_VERSION}"
csi_external_snapshotter_image_version = "${CSI_EXTERNAL_SNAPSHOTTER_IMAGE_VERSION}"
snapscheduler_helm_chart_version = "${SNAPSCHEDULER_HELM_CHART_VERSION}"     
EOF

terraform init -reconfigure \
  -backend-config="bucket=tf-state-${AWS_REGION}-${AWS_ACCOUNT_ID}" \
  -backend-config="key=${NETWORK_NAME}/${CLUSTER_NAME}/${DEPLOYMENT_NAME}/terraform.tfstate" \
  -backend-config="region=${AWS_REGION}" \
  -backend-config="encrypt=true" \
  -backend-config="dynamodb_table=tf-state-${AWS_REGION}-${AWS_ACCOUNT_ID}"

aws eks update-kubeconfig --region $AWS_REGION --name "${NETWORK_NAME}-${CLUSTER_NAME}"

# https://github.com/backube/snapscheduler/releases/tag/v3.2.0
kubectl get crd | grep -q "snapshotschedules.snapscheduler.backube"

if [[ $(echo $?) == 0 ]];
then
  kubectl label crd/snapshotschedules.snapscheduler.backube app.kubernetes.io/managed-by=Helm
  kubectl annotate crd/snapshotschedules.snapscheduler.backube meta.helm.sh/release-name=snapscheduler --overwrite
  kubectl annotate crd/snapshotschedules.snapscheduler.backube meta.helm.sh/release-namespace=snapscheduler --overwrite
fi

if [[ $ACTION == "destroy" ]] && [[ -f ${BACKEND_CONFIG_DIRECTORY_PATH}/terraform/terraform.tfvars ]];
then
  mv ${BACKEND_CONFIG_DIRECTORY_PATH}/terraform/terraform.tfvars terraform.tfvars
fi

terraform $ACTION --auto-approve

TERRAFORM_RUN_EXIT_CODE=$(echo $?)

mv terraform.tfvars ${BACKEND_CONFIG_DIRECTORY_PATH}/terraform/${DEPLOYMENT_NAME}/terraform.tfvars
terraform state pull > ${BACKEND_CONFIG_DIRECTORY_PATH}/terraform/${DEPLOYMENT_NAME}/terraform.tfstate

exit $TERRAFORM_RUN_EXIT_CODE
