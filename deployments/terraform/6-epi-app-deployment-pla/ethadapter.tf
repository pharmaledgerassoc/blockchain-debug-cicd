# --- 6-epi-app-deployment-pla/ethadapter.tf ---

resource "null_resource" "ethadapter" {
  depends_on = [
    data.local_file.config_context_sh,
    local_file.eth_values_yaml,
    local_file.github_info_yaml,
    local_file.ethadapter_values_plugin_yaml,
    local_file.ethadapter_secretsmanager_yaml
  ]

  provisioner "local-exec" {
    command = "helm pl-plugin --ethAdapter -i ${local.eth_values_path} ${local.gh_info_path} ${path.module}/github.info.yaml ${local.eth_service_path} ${local.qn_info_path} ${local.smart_contract_info_path} ${local.eth_info_path} ${local.tmp_folder_path}/ethadapter-values-plugin.yaml ${local.tmp_folder_path}/rpc-address.yaml ${local.tmp_folder_path}/networkName.yaml ${local.tmp_folder_path}/ethadapter-secretsmanager.yaml -o ${local.tmp_folder_path}"
  }
}

resource "aws_secretsmanager_secret" "ethadapter" {
  #checkov:skip=CKV2_AWS_57:Ensure Secrets Manager secrets should have automatic rotation enabled

  name_prefix = "${var.network_name}-${var.cluster_name}-ethadapter"
  kms_key_id  = aws_kms_key.ethadapter.arn
}
resource "aws_secretsmanager_secret_version" "ethadapter" {
  secret_id     = aws_secretsmanager_secret.ethadapter.id
  secret_string = data.local_file.org_account_json.content
}
resource "aws_secretsmanager_secret_policy" "ethadapter" {
  secret_arn = aws_secretsmanager_secret.ethadapter.arn
  policy     = <<EOF
{
  "Version" : "2012-10-17",
  "Statement" : [
    {
      "Effect" : "Allow",
      "Principal" : {
        "AWS" : "${aws_iam_role.ethadapter.arn}"
      },
      "Action" : ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"],
      "Resource" : "*"
    }
  ]
}
EOF
}

resource "helm_release" "ethadapter" {
  depends_on = [
    null_resource.ethadapter,
    local_file.eth_values_yaml,
    local_file.ethadapter_values_chart_yaml
  ]

  name = "ethadapter"

  repository = local.https_url_helm_charts_repository
  chart      = "ethadapter"
  version    = var.ethadapter_helm_chart_version

  replace = true
  wait    = true
  timeout = 300

  values = [
    file(local.eth_service_path),
    file(local.eth_info_path),
    data.local_file.eth_values_yaml.content,
    data.local_file.ethadapter_values_chart_yaml.content,
    file("${local.tmp_folder_path}/rpc-address.yaml"),
    data.local_file.ethadapter_secretsmanager_yaml.content
  ]
}

data "kubernetes_service" "ethadapter" {
  depends_on = [
    helm_release.ethadapter
  ]

  metadata {
    name = "ethadapter"
  }
}
