# --- bundle-eks-essentials/main.tf ---

module "aws_loadbalancer_controller" {
  source = "./modules/aws-loadbalancer-controller"

  vpc_id = var.vpc_id

  eks_cluster_name  = var.eks_cluster_name
  oidc_provider_url = var.oidc_provider_url

  helm_chart_version = var.aws_load_balancer_helm_chart_version

  image_version = var.aws_load_balancer_image_version
}

module "aws_fluent_bit" {
  source = "./modules/aws-for-fluent-bit"

  eks_cluster_name  = var.eks_cluster_name
  oidc_provider_url = var.oidc_provider_url

  helm_chart_version = var.fluent_bit_helm_chart_version

  image_version = var.fluent_bit_image_version
}
