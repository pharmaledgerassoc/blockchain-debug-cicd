# --- aws-loadbalancer-controller/variables.tf ---

variable "helm_chart_version" {
  type = string
}

variable "image_version" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "eks_cluster_name" {
  type = string
}
variable "oidc_provider_url" {
  type = string
}
