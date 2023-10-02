# --- 4-quorum-node-pla/files.tf ---

data "local_file" "config_context_sh" {
  filename = "${var.env_dir_path}/config-context.sh"
}

data "local_file" "new_network_plugin_secrets_json" {
  filename = "${local.tmp_folder_path}/new-network.plugin.secrets.json"
}

data "local_file" "join_network_plugin_secrets_json" {
  filename = "${local.tmp_folder_path}/join-network.plugin.secrets.json"
}

resource "local_file" "rpc_address_yaml" {
  filename = "${local.tmp_folder_path}/rpc-address.yaml"

  content = templatefile("${path.module}/templates/rpc-address.yaml.tftpl", { rpc_ip = data.kubernetes_service.quorum_rpc.spec[0].cluster_ip })
}

resource "local_file" "github_info_yaml" {
  filename = "${path.module}/github.info.yaml"

  content = templatefile("${path.module}/templates/github.info.yaml.tftpl", { read_write_token = var.github_read_write_token })
}

resource "local_file" "genesis_geth_json" {
  count = fileexists("${var.net_dir_path}/smartContractAbi.json") ? 0 : 1

  filename = local.genesis_geth_path

  content = chomp(jsondecode(replace(jsonencode(data.kubernetes_config_map.main.data), ".", "_")).genesis-geth_json)
}

resource "local_file" "enode" {
  filename = local.enode_path

  content = "enode://${chomp(jsondecode(replace(jsonencode(data.kubernetes_config_map.main.data), ".", "_")).enode)}@${data.aws_eip.main.public_ip}:30303?discport=0"
}

resource "local_file" "validator" {
  filename = local.validator_path

  content = regex("0x[[:alnum:]]{40,}?", jsonencode(jsondecode(replace(jsonencode(data.kubernetes_config_map.main.data), ".", "_")).istanbul-validator-config_toml))
}

resource "local_file" "secretsmanager_yaml" {
  filename = "${local.tmp_folder_path}/secretsmanager.yaml"

  content = templatefile("${path.module}/templates/secretsmanager.yaml.tftpl", { role_arn = aws_iam_role.main.arn, secretsmanager_arn = aws_secretsmanager_secret.main.arn })
}

data "local_file" "secretsmanager_yaml" {
  depends_on = [
    local_file.secretsmanager_yaml
  ]

  filename = "${local.tmp_folder_path}/secretsmanager.yaml"
}
