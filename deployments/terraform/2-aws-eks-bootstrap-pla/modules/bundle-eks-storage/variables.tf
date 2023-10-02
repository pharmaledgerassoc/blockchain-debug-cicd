# --- bundle-eks-storage/variables.tf ---

variable "eks_cluster_name" {
  type        = string
  description = "The Name/ID of the EKS Cluster."
}
variable "oidc_provider_url" {
  type        = string
  description = "URL of the AWS OIDC Provider associated with the EKS cluster"
}

variable "aws_csi_secrets_store_provider_helm_chart_version" {
  type = string
}
variable "aws_csi_secrets_store_provider_image_version" {
  type = string
}

variable "ebs_csi_driver_version" {
  type = string
}

variable "csi_external_snapshotter_image_version" {
  type = string
}

variable "snapscheduler_helm_chart_version" {
  type = string
}
