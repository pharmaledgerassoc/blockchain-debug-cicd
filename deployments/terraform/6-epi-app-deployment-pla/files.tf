# --- 6-epi-app-deployment-pla/files.tf ---

data "local_file" "config_context_sh" {
  filename = "${var.env_dir_path}/config-context.sh"
}

data "http" "eth_values_yaml" {
  url = local.https_url_eth_values_yaml
}
resource "local_file" "eth_values_yaml" {
  filename = local.eth_values_path

  content = data.http.eth_values_yaml.response_body
}
data "local_file" "eth_values_yaml" {
  depends_on = [
    local_file.eth_values_yaml
  ]

  filename = local.eth_values_path
}

resource "local_file" "github_info_yaml" {
  filename = "${path.module}/github.info.yaml"

  content = templatefile("${path.module}/templates/github.info.yaml.tftpl", { read_write_token = var.github_read_write_token })
}

resource "local_file" "ethadapter_values_plugin_yaml" {
  filename = "${local.tmp_folder_path}/ethadapter-values-plugin.yaml"

  content = templatefile("${path.module}/templates/ethadapter-values-plugin.yaml.tftpl", { repository_name = local.gh_repository_name, read_write_token = var.github_read_write_token, smart_contract_info_name = local.smart_contract_info_name })
}

data "local_file" "org_account_json" {
  depends_on = [
    null_resource.ethadapter
  ]

  filename = "${local.tmp_folder_path}/orgAccount.json"
}

data "local_file" "ethadapter_plugin_json" {
  depends_on = [
    null_resource.ethadapter
  ]

  filename = "${local.tmp_folder_path}/eth-adapter.plugin.json"
}

resource "local_file" "ethadapter_values_chart_yaml" {
  filename = "${local.tmp_folder_path}/ethadapter-values-chart.yaml"

  content = templatefile("${path.module}/templates/ethadapter-values-chart.yaml.tftpl",
    { ethadapter_image_repository  = var.ethadapter_image_repository,
      ethadapter_image_version     = var.ethadapter_image_version,
      ethadapter_image_version_sha = var.ethadapter_image_version_sha,

      smart_contract_info = data.local_file.ethadapter_plugin_json.content,
  org_account_json = data.local_file.org_account_json.content })
}
data "local_file" "ethadapter_values_chart_yaml" {
  depends_on = [
    local_file.ethadapter_values_chart_yaml
  ]

  filename = "${local.tmp_folder_path}/ethadapter-values-chart.yaml"
}

resource "local_file" "ethadapter_secretsmanager_yaml" {
  filename = "${local.tmp_folder_path}/ethadapter-secretsmanager.yaml"

  content = templatefile("${path.module}/templates/ethadapter-secretsmanager.yaml.tftpl", { role_arn = aws_iam_role.ethadapter.arn, secretsmanager_arn = aws_secretsmanager_secret.ethadapter.arn })
}
data "local_file" "ethadapter_secretsmanager_yaml" {
  depends_on = [
    local_file.ethadapter_secretsmanager_yaml
  ]

  filename = "${local.tmp_folder_path}/ethadapter-secretsmanager.yaml"
}

resource "local_file" "epi_info_yaml" {
  filename = local.epi_info_path

  content = templatefile("${path.module}/templates/epi.info.yaml.tftpl",
    { epi_runner_image_repository  = var.epi_runner_image_repository,
      epi_runner_image_version     = var.epi_runner_image_version,
      epi_runner_image_version_sha = var.epi_runner_image_version_sha,

      epi_builder_image_repository  = var.epi_builder_image_repository,
      epi_builder_image_version     = var.epi_builder_image_version,
      epi_builder_image_version_sha = var.epi_builder_image_version_sha,

      domain                     = var.domain,
      sub_domain                 = var.sub_domain,
      vault_domain               = var.vault_domain,
      ethadapter_url             = "http://${data.kubernetes_service.ethadapter.spec[0].cluster_ip}:${data.kubernetes_service.ethadapter.spec[0].port[0].port}",
      company_name               = var.cluster_name,
      build_secret_key           = var.build_secret_key,
      sso_secrets_encryption_key = var.sso_secrets_encryption_key,

      oauth_jwks_endpoint    = var.oauth_jwks_endpoint,
      issuer                 = var.issuer,
      authorization_endpoint = var.authorization_endpoint,
      token_endpoint         = var.token_endpoint,

      client_id     = var.client_id,
      client_secret = var.client_secret,

      dns_name = var.dns_name,

  logout_url = var.logout_url })
}
data "local_file" "epi_info_yaml" {
  depends_on = [
    local_file.epi_info_yaml
  ]

  filename = local.epi_info_path
}

data "local_file" "epi_service_yaml" {
  filename = local.epi_service_path
}

resource "local_file" "epi_secretsmanager_yaml" {
  filename = "${local.tmp_folder_path}/epi-secretsmanager.yaml"

  content = templatefile("${path.module}/templates/epi-secretsmanager.yaml.tftpl", { role_arn = aws_iam_role.epi.arn, secretsmanager_arn = aws_secretsmanager_secret.epi.arn })
}
data "local_file" "epi_secretsmanager_yaml" {
  depends_on = [
    local_file.epi_secretsmanager_yaml
  ]

  filename = "${local.tmp_folder_path}/epi-secretsmanager.yaml"
}
