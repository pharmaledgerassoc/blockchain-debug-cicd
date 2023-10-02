# --- 6-epi-app-deployment-pla/variables.tf ---

variable "network_name" {
  type = string
}
variable "cluster_name" {
  type = string
}

variable "kube_config_path" {
  type = string
}

variable "env_dir_path" {
  type = string
}

variable "github_read_write_token" {
  type = string
}
variable "ethadapter_helm_chart_version" {
  type = string
}

variable "ethadapter_image_repository" {
  type = string
}
variable "ethadapter_image_version" {
  type = string
}
variable "ethadapter_image_version_sha" {
  type = string
}

variable "epi_helm_chart_version" {
  type = string
}

variable "dns_name" {
  type = string
}
variable "domain" {
  type = string
}
variable "sub_domain" {
  type = string
}
variable "vault_domain" {
  type = string
}

variable "epi_runner_image_repository" {
  type = string
}
variable "epi_runner_image_version" {
  type = string
}
variable "epi_runner_image_version_sha" {
  type = string
}

variable "epi_builder_image_repository" {
  type = string
}
variable "epi_builder_image_version" {
  type = string
}
variable "epi_builder_image_version_sha" {
  type = string
}

variable "build_secret_key" {
  type = string
}
variable "sso_secrets_encryption_key" {
  type = string
}

variable "oauth_jwks_endpoint" {
  type = string
}
variable "issuer" {
  type = string
}
variable "authorization_endpoint" {
  type = string
}
variable "token_endpoint" {
  type = string
}

variable "client_id" {
  type = string
}
variable "client_secret" {
  type = string
}

variable "logout_url" {
  type = string
}
