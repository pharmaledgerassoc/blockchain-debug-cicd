# --- 1-aws-eks-infrastructure-pla/modules/vpc/subnets/providers.tf ---

terraform {
  required_version = "~> 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.17"
    }
  }
}
