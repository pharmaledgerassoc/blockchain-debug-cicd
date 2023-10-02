# --- 3-initialize-environment-pla/variables.tf ---

variable "aws_region" {
  type = string
}

variable "network_name" {
  type = string
}
variable "cluster_name" {
  type = string
}

variable "env_dir_path" {
  type = string
}
variable "net_dir_path" {
  type = string
}

variable "github_repository_name" {
  type = string
}
variable "github_read_write_token" {
  type = string
}

variable "helm_chart_version" {
  type = string
}
