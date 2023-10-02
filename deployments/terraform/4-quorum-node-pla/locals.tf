# --- 4-quorum-node-pla/locals.tf ---

locals {
  https_url_helm_charts_repository = "https://pharmaledgerassoc.github.io/helm-charts"

  tmp_folder_path   = regex("TMP_FOLDER_PATH=(.+)", data.local_file.config_context_sh.content)[0]
  genesis_geth_path = regex("genesisGethPath=(.+)", data.local_file.config_context_sh.content)[0]

  join_path                   = regex("joinPath=(.+)", data.local_file.config_context_sh.content)[0]
  enode_path                  = regex("enodePath=(.+)", data.local_file.config_context_sh.content)[0]
  validator_path              = regex("validatorPath=(.+)", data.local_file.config_context_sh.content)[0]
  oidc_provider_arn           = "arn:aws:iam::${data.aws_caller_identity.main.account_id}:oidc-provider/${trim(data.aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://")}"
  new_network_service         = regex("newNetworkService=(.+)", data.local_file.config_context_sh.content)[0]
  join_network_info           = regex("joinNetworkInfo=(.+)", data.local_file.config_context_sh.content)[0]
  qn_values_path              = regex("qnValuesPath=(.+)", data.local_file.config_context_sh.content)[0]
  qn_info_path                = regex("qnInfoPath=(.+)", data.local_file.config_context_sh.content)[0]
  network_config_values       = fileexists(local.join_path) ? local.join_network_info : local.new_network_service
  smart_contract_info_path    = regex("smartContractInfoPath=(.+)", data.local_file.config_context_sh.content)[0]
  network_plugin_secrets_json = fileexists(local.join_path) ? data.local_file.join_network_plugin_secrets_json.content : data.local_file.new_network_plugin_secrets_json.content
  gh_info_path                = regex("ghInfoPath=(.+)", data.local_file.config_context_sh.content)[0]
}
