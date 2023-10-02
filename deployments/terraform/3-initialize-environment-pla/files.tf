# --- 3-initialize-environment-pla/files.tf ---

resource "local_file" "main" {
  for_each = fileset(path.module, "../../company-private-configs/network-name/**")

  filename = replace(regex("network-name\\/.+", each.key), "network-name/", "${var.env_dir_path}/")

  content = file(each.key)
}

resource "local_file" "tmp" {
  filename = "${local.tmp_folder_path}/.tmp"

  content = ""
}

resource "local_file" "config_context_sh" {
  filename = "${var.env_dir_path}/config-context.sh"

  content = templatefile("${path.module}/templates/config-context.sh.tftpl", { network_name = var.network_name, company_name = var.cluster_name, env_dir_path = var.env_dir_path, net_dir_path = var.net_dir_path })
}

resource "local_file" "deployment_yaml" {
  depends_on = [
    local_file.tmp
  ]

  filename = "${local.tmp_folder_path}/deployment.yaml"

  content = templatefile("${path.module}/templates/deployment.yaml.tftpl", { network_name = var.network_name, company = var.cluster_name, enode_address = data.aws_eip.main.public_ip })
}

data "local_file" "config_context_sh" {
  depends_on = [
    local_file.config_context_sh
  ]

  filename = "${var.env_dir_path}/config-context.sh"
}

data "http" "qn_values_yaml" {
  url = local.https_url_qn_values_yaml
}
resource "local_file" "qn_values_yaml" {
  filename = regex("qnValuesPath=(.+)", data.local_file.config_context_sh.content)[0]

  content = data.http.qn_values_yaml.response_body
}

resource "local_file" "network_name_yaml" {
  depends_on = [
    local_file.tmp
  ]

  filename = "${local.tmp_folder_path}/networkName.yaml"

  content = templatefile("${path.module}/templates/networkName.yaml.tftpl", { network_name = var.network_name })
}

data "local_file" "new_network_plugin_secrets_json" {
  depends_on = [
    null_resource.helm_pl_plugin_new_network_service
  ]

  filename = "${local.tmp_folder_path}/new-network.plugin.secrets.json"
}
data "local_file" "new_network_plugin_json" {
  depends_on = [
    null_resource.helm_pl_plugin_new_network_service
  ]

  filename = "${local.tmp_folder_path}/new-network.plugin.json"
}
resource "local_file" "new_network_service_yaml" {
  filename = local.new_network_service

  content = templatefile("${path.module}/templates/new-network-service.yaml.tftpl", { plugin_data_common = data.local_file.new_network_plugin_json.content, plugin_data_secrets = data.local_file.new_network_plugin_secrets_json.content, aws_load_balancer_subnets = data.aws_subnets.main.ids[0], aws_load_balancer_eip_allocations = data.aws_eip.main.id, aws_load_balancer_name = "${var.network_name}-${var.cluster_name}-quorum-node-qn-0" })
}

data "local_file" "join_network_plugin_secrets_json" {
  depends_on = [
    null_resource.helm_pl_plugin_join_network_info
  ]

  filename = "${local.tmp_folder_path}/join-network.plugin.secrets.json"
}
data "local_file" "join_network_plugin_json" {
  depends_on = [
    null_resource.helm_pl_plugin_join_network_info
  ]

  filename = "${local.tmp_folder_path}/join-network.plugin.json"
}
resource "local_file" "join_network_info_yaml" {
  filename = local.join_network_info

  content = templatefile("${path.module}/templates/join-network.info.yaml.tftpl", { plugin_data_common = data.local_file.join_network_plugin_json.content, plugin_data_secrets = data.local_file.join_network_plugin_secrets_json.content, aws_load_balancer_subnets = data.aws_subnets.main.ids[0], aws_load_balancer_eip_allocations = data.aws_eip.main.id, aws_load_balancer_name = "${var.network_name}-${var.cluster_name}-quorum-node-qn-0" })
}

resource "local_file" "github_info_yaml" {
  depends_on = [
    local_file.main
  ]

  filename = local.gh_info_path

  content = templatefile("${path.module}/templates/github.info.yaml.tftpl", { repository_name = var.github_repository_name })
}

resource "local_file" "github_info_yaml_token" {
  depends_on = [
    local_file.github_info_yaml
  ]

  filename = "${path.module}/github.info.yaml"
  content  = replace(file(local.gh_info_path), "read_write_token: \"\"", "read_write_token: \"${var.github_read_write_token}\"")
}

resource "local_file" "join" {
  depends_on = [
    local_file.config_context_sh
  ]

  count = fileexists("${var.net_dir_path}/smartContractAbi.json") ? 1 : 0

  filename = local.join_path

  content = ""
}
