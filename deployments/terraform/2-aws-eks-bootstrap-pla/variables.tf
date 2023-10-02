# --- 2-aws-eks-bootstrap-pla/variables.tf ---

variable "aws_region" {
  type = string
}

variable "network_name" {
  type = string
}
variable "cluster_name" {
  type = string
}

variable "kube_config_path" {
  type = string
}

variable "vpc_cni_version" {
  type = string
}

variable "kube_proxy_version" {
  type = string
}

variable "coredns_version" {
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
