# --- bundle-eks/storage/main.tf ---

module "csi_external_snapshotter" {
  source = "./modules/csi-external-snapshotter"

  image_version = var.csi_external_snapshotter_image_version
}

module "aws_ebs_csi_driver" {
  depends_on = [
    module.csi_external_snapshotter
  ]

  source = "./modules/aws-ebs-csi-driver"

  eks_cluster_name  = var.eks_cluster_name
  oidc_provider_url = var.oidc_provider_url

  ebs_csi_driver_version = var.ebs_csi_driver_version
}

module "snapscheduler" {
  depends_on = [
    module.csi_external_snapshotter,
    module.aws_ebs_csi_driver
  ]

  source = "./modules/snapscheduler"

  helm_chart_version = var.snapscheduler_helm_chart_version
}

module "aws_csi_secrets_store_provider" {
  source = "./modules/aws-csi-secrets-store-provider"

  helm_chart_version = var.aws_csi_secrets_store_provider_helm_chart_version

  image_version = var.aws_csi_secrets_store_provider_image_version
}

module "volumesnapshotclass_csi_aws" {
  depends_on = [
    module.csi_external_snapshotter
  ]

  source = "./modules/volumesnapshotclass-csi-aws"
}
