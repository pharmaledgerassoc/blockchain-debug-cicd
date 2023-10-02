# --- 6-epi-app-deployment-pla/locals.tf ---

locals {
  https_url_eth_values_yaml        = "https://raw.githubusercontent.com/pharmaledgerassoc/helm-charts/ethadapter-${var.ethadapter_helm_chart_version}/charts/ethadapter/values.yaml"
  https_url_helm_charts_repository = "https://pharmaledgerassoc.github.io/helm-charts"
  https_url_apihub_json_template   = "https://raw.githubusercontent.com/pharmaledgerassoc/epi-workspace/master/apihub-root/external-volume/config/apihub.json.template"

  tmp_folder_path = regex("TMP_FOLDER_PATH=(.+)", data.local_file.config_context_sh.content)[0]

  eth_info_path    = regex("ethInfoPath=(.+)", data.local_file.config_context_sh.content)[0]
  eth_values_path  = regex("ethValuesPath=(.+)", data.local_file.config_context_sh.content)[0]
  eth_service_path = regex("ethServicePath=(.+)", data.local_file.config_context_sh.content)[0]

  epi_info_path    = regex("epiInfoPath=(.+)", data.local_file.config_context_sh.content)[0]
  epi_service_path = regex("epiServicePath=(.+)", data.local_file.config_context_sh.content)[0]

  gh_info_path       = regex("ghInfoPath=(.+)", data.local_file.config_context_sh.content)[0]
  qn_info_path       = regex("qnInfoPath=(.+)", data.local_file.config_context_sh.content)[0]
  gh_repository_name = regex("repository_name:(.+)", file(local.gh_info_path))[0]

  smart_contract_info_path = regex("smartContractInfoPath=(.+)", data.local_file.config_context_sh.content)[0]
  smart_contract_info_name = regex("smartContractInfoName:(.+)", file(local.eth_info_path))[0]

  oidc_provider_arn = "arn:aws:iam::${data.aws_caller_identity.main.account_id}:oidc-provider/${trim(data.aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://")}"
}
