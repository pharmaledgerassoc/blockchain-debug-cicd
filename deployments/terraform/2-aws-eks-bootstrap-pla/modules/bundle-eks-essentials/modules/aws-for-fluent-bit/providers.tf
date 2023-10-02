# --- 2-aws-eks-bootstrap-pla/modules/aws-for-fluent-bit/providers.tf ---

terraform {
  required_version = "~> 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.17"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
  }
}
