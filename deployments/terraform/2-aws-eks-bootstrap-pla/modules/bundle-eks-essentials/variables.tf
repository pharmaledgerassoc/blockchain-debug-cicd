# --- bundle-eks-essentials/main.tf ---

variable "vpc_id" {
  type = string
}

variable "eks_cluster_name" {
  type = string
}
variable "oidc_provider_url" {
  type = string
}

variable "fluent_bit_helm_chart_version" {
  type = string
}
variable "fluent_bit_image_version" {
  type = string
}

variable "aws_load_balancer_helm_chart_version" {
  type = string
}
variable "aws_load_balancer_image_version" {
  type = string
}
