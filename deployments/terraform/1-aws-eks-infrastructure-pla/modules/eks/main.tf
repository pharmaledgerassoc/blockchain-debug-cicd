# --- eks/main.tf ---

data "aws_region" "main" {}
data "aws_caller_identity" "main" {}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.16"

  cluster_name    = "${var.network_name}-${var.cluster_name}"
  cluster_version = var.cluster_version

  cluster_endpoint_private_access = false
  cluster_endpoint_public_access  = true

  create_cloudwatch_log_group = true

  cloudwatch_log_group_retention_in_days = 30
  cloudwatch_log_group_kms_key_id        = aws_kms_key.main.arn

  cluster_enabled_log_types = [
    "audit",
    "api",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]

  vpc_id                   = var.vpc_id
  subnet_ids               = var.subnet_nodes_ids
  control_plane_subnet_ids = var.subnet_controlplane_ids

  create_kms_key = false

  cluster_encryption_config = {
    provider_key_arn = aws_kms_key.main.arn
    resources        = ["secrets"]
  }

  manage_aws_auth_configmap = true

  aws_auth_users    = var.auth_users
  aws_auth_roles    = var.auth_roles
  aws_auth_accounts = var.auth_accounts

  tags = {
    Name    = "${var.network_name}-${var.cluster_name}"
    Network = var.network_name
    Cluster = var.cluster_name
  }

  eks_managed_node_group_defaults = {
    iam_role_additional_policies = {
      AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    }

    instance_types = [var.instance_type]
  }
  eks_managed_node_groups = {
    default-1a = {
      subnet_ids = [var.subnet_nodes_ids[0]]

      min_size     = 0
      max_size     = 3
      desired_size = 2

      tags = {
        Name    = "${var.network_name}-${var.cluster_name}-${data.aws_region.main.name}a"
        Network = var.network_name
        Cluster = var.cluster_name
      }

      metadata_options = {
        http_endpoint               = "enabled"
        http_tokens                 = "required"
        http_put_response_hop_limit = 1
      }
      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            delete_on_termination = true
            encrypted             = true
            kms_key_id            = aws_kms_key.main.arn
            volume_size           = 100
            volume_type           = "gp3"
          }
        }
      }
    }
  }
}
