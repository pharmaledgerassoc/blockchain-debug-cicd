# --- 1-aws-eks-infrastructure-pla/main.tf ---

module "vpc" {
  source = "./modules/vpc"

  cluster_name = var.cluster_name
  network_name = var.network_name

  enable_single_natgw = var.enable_single_natgw
}

module "eks" {
  source = "./modules/eks"

  cluster_name = var.cluster_name
  network_name = var.network_name
  vpc_id       = module.vpc.vpc_id



  subnet_controlplane_ids = module.vpc.subnet_private_eks_controlplane_ids
  subnet_nodes_ids        = module.vpc.subnet_private_eks_nodegroup_ids

  cluster_version = var.cluster_version
  instance_type   = "t3.xlarge"

  auth_users    = var.eks_auth_users
  auth_roles    = var.eks_auth_roles
  auth_accounts = var.eks_auth_accounts
}

resource "local_file" "region" {
  filename = "${var.backend_config_directory_path}/region"

  content = var.aws_region
}
