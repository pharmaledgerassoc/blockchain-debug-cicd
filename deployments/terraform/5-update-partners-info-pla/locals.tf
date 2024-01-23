# --- 5-update-partners-info-pla/locals.tf ---

locals {
  tmp_folder_path = regex("TMP_FOLDER_PATH=(.+)", data.local_file.config_context_sh.content)[0]

  join_path             = regex("joinPath=(.+)", data.local_file.config_context_sh.content)[0]
  new_network_service   = regex("newNetworkService=(.+)", data.local_file.config_context_sh.content)[0]
  join_network_info     = regex("joinNetworkInfo=(.+)", data.local_file.config_context_sh.content)[0]
  qn_values_path        = regex("qnValuesPath=(.+)", data.local_file.config_context_sh.content)[0]
  qn_info_path          = regex("qnInfoPath=(.+)", data.local_file.config_context_sh.content)[0]
  gh_info_path          = regex("ghInfoPath=(.+)", data.local_file.config_context_sh.content)[0]
  update_partners_peers = replace(jsonencode(setsubtract(fileset("${var.net_dir_path}/editable", "/*/enode"), ["${var.cluster_name}/enode"])), "/enode", "")
  network_config_values = fileexists(local.join_path) ? local.join_network_info : local.new_network_service
}
