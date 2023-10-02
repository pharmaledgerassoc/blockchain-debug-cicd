# --- 2-aws-eks-bootstrap-pla/modules/aws-for-fluent-bit/variables.tf ---

variable "helm_chart_version" {
  type = string
}

variable "image_version" {
  type = string
}

variable "eks_cluster_name" {
  type = string
}
variable "oidc_provider_url" {
  type = string
}
