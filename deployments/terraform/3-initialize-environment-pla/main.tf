# --- 3-initialize-environment-pla/main.tf ---

data "aws_eip" "main" {
  filter {
    name   = "tag:Name"
    values = ["${var.network_name}-${var.cluster_name}-quorum-node-qn-0-eip"]
  }
}

data "aws_subnets" "main" {
  filter {
    name   = "tag:Name"
    values = ["${var.network_name}-${var.cluster_name}-public-nlb-subnet-1a"]
  }
}

resource "null_resource" "helm_pl_plugin_new_network_service" {
  depends_on = [
    local_file.main,
    local_file.tmp,
    local_file.network_name_yaml,
    local_file.deployment_yaml,
    local_file.qn_values_yaml,

    data.local_file.config_context_sh
  ]

  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = "helm pl-plugin --newNetwork -i ${local.qn_values_path} ${local.gh_info_path} ${path.module}/github.info.yaml ${local.qn_info_path} ${local.new_network_service} ${local.tmp_folder_path}/deployment.yaml -o ${local.tmp_folder_path}"
  }
}

resource "null_resource" "helm_pl_plugin_join_network_info" {
  depends_on = [
    local_file.main,
    local_file.tmp,
    local_file.network_name_yaml,
    local_file.deployment_yaml,
    local_file.qn_values_yaml,

    data.local_file.config_context_sh
  ]

  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = "helm pl-plugin --joinNetwork -i ${local.qn_values_path} ${local.gh_info_path} ${path.module}/github.info.yaml ${local.qn_info_path} ${local.join_network_info} ${local.tmp_folder_path}/deployment.yaml -o ${local.tmp_folder_path}"
  }
}
