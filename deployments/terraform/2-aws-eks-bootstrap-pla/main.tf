# --- 2-aws-eks-bootstrap-pla/main.tf ---

data "aws_eks_cluster" "main" {
  name = "${var.network_name}-${var.cluster_name}"
}

module "bundle-eks-essentials" {
  source = "./modules/bundle-eks-essentials"

  vpc_id = data.aws_eks_cluster.main.vpc_config[0].vpc_id

  eks_cluster_name  = data.aws_eks_cluster.main.name
  oidc_provider_url = data.aws_eks_cluster.main.identity[0].oidc[0].issuer

  fluent_bit_helm_chart_version = var.fluent_bit_helm_chart_version
  fluent_bit_image_version      = var.fluent_bit_image_version

  aws_load_balancer_helm_chart_version = var.aws_load_balancer_helm_chart_version
  aws_load_balancer_image_version      = var.aws_load_balancer_image_version
}

module "bundle-eks-storage" {
  source = "./modules/bundle-eks-storage"

  eks_cluster_name  = data.aws_eks_cluster.main.name
  oidc_provider_url = data.aws_eks_cluster.main.identity[0].oidc[0].issuer

  aws_csi_secrets_store_provider_helm_chart_version = var.aws_csi_secrets_store_provider_helm_chart_version
  aws_csi_secrets_store_provider_image_version      = var.aws_csi_secrets_store_provider_image_version

  ebs_csi_driver_version = var.ebs_csi_driver_version

  csi_external_snapshotter_image_version = var.csi_external_snapshotter_image_version

  snapscheduler_helm_chart_version = var.snapscheduler_helm_chart_version
}

module "bundle-eks-managed-addons" {
  depends_on = [
    module.bundle-eks-storage
  ]

  source = "./modules/bundle-eks-managed-addons"

  eks_cluster_name  = data.aws_eks_cluster.main.name
  oidc_provider_url = data.aws_eks_cluster.main.identity[0].oidc[0].issuer

  vpc_cni_version    = var.vpc_cni_version
  kube_proxy_version = var.kube_proxy_version
  coredns_version    = var.coredns_version
}
