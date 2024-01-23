# --- 5-update-partners-info-pla/main.tf ---

data "aws_region" "main" {}

resource "null_resource" "main" {
  depends_on = [
    local_file.update_partners_info_yaml
  ]

  provisioner "local-exec" {
    command = "helm pl-plugin --updatePartnersInfo -i ${local.qn_values_path} ${local.gh_info_path} ${path.module}/github.info.yaml ${local.network_config_values} ${local.qn_info_path} ${local.tmp_folder_path}/deployment.yaml ${local.tmp_folder_path}/networkName.yaml ${local.tmp_folder_path}/update-partners.info.yaml ${local.tmp_folder_path}/secretsmanager.yaml -o ${local.tmp_folder_path}"
  }

  triggers = {
    always_run = timestamp()
  }
}

resource "null_resource" "qn_0" {
  depends_on = [
    null_resource.main
  ]

  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = "helm upgrade --install --debug --wait --timeout=600s qn-0 pharmaledgerassoc/quorum-node -f ${local.qn_values_path} -f ${local.gh_info_path} -f ${path.module}/github.info.yaml -f ${local.qn_info_path} -f ${local.network_config_values} -f ${local.tmp_folder_path}/deployment.yaml -f ${local.tmp_folder_path}/networkName.yaml -f ${local.tmp_folder_path}/update-partners.info.yaml --set-file use_case.updatePartnersInfo.plugin_data_common=${local.tmp_folder_path}/update-partners-info.plugin.json -f ${path.module}/values.yaml -f ${local.tmp_folder_path}/secretsmanager.yaml"
  }
}
