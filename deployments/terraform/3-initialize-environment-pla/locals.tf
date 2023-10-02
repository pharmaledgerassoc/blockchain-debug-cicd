# --- 3-initialize-environment-pla/locals.tf ---

locals {
  https_url_qn_values_yaml = "https://raw.githubusercontent.com/pharmaledgerassoc/helm-charts/quorum-node-${var.helm_chart_version}/charts/quorum-node/values.yaml"

  tmp_folder_path     = regex("TMP_FOLDER_PATH=(.+)", data.local_file.config_context_sh.content)[0]
  new_network_service = regex("newNetworkService=(.+)", data.local_file.config_context_sh.content)[0]
  join_network_info   = regex("joinNetworkInfo=(.+)", data.local_file.config_context_sh.content)[0]
  gh_info_path        = regex("ghInfoPath=(.+)", data.local_file.config_context_sh.content)[0]
  qn_info_path        = regex("qnInfoPath=(.+)", data.local_file.config_context_sh.content)[0]
  join_path           = regex("joinPath=(.+)", data.local_file.config_context_sh.content)[0]
  qn_values_path      = regex("qnValuesPath=(.+)", data.local_file.config_context_sh.content)[0]
}
