# --- 5-update-partners-info-pla/variables.tf ---

variable "cluster_name" {
  type = string
}

variable "env_dir_path" {
  type = string
}
variable "net_dir_path" {
  type = string
}

variable "kube_config_path" {
  type = string
}

variable "github_read_write_token" {
  type = string
}
