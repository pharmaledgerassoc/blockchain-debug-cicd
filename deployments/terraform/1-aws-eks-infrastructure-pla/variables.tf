# --- 0-aws-eks-infrastructure-pla/variables.tf ---

variable "aws_region" {
  type = string
}

variable "network_name" {
  type = string
}
variable "cluster_name" {
  type = string
}
variable "cluster_version" {
  type = string
}

variable "enable_single_natgw" {
  type    = bool
  default = true
}

variable "kube_config_path" {
  type = string
}

variable "backend_config_directory_path" {
  type = string
}

variable "eks_auth_users" {
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}
variable "eks_auth_roles" {
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}
variable "eks_auth_accounts" {
  type    = list(string)
  default = []
}
