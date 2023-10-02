# --- bundle-eks-storage/variables.tf ---

variable "eks_cluster_name" {
  type = string
}
variable "oidc_provider_url" {
  type = string
}

# https://docs.aws.amazon.com/eks/latest/userguide/ebs-csi.html
variable "ebs_csi_driver_version" {
  type = string
}
