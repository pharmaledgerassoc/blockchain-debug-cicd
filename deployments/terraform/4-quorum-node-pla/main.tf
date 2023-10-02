# --- 4-quorum-node-pla/main.tf ---

data "aws_eip" "main" {
  filter {
    name   = "tag:Name"
    values = ["${var.network_name}-${var.cluster_name}-quorum-node-qn-0-eip"]
  }
}

data "aws_region" "main" {}
data "aws_caller_identity" "main" {}

data "aws_eks_cluster" "main" {
  name = "${var.network_name}-${var.cluster_name}"
}

resource "aws_secretsmanager_secret" "main" {
  #checkov:skip=CKV2_AWS_57:Ensure Secrets Manager secrets should have automatic rotation enabled

  name_prefix = "${var.network_name}-${var.cluster_name}-quorum-node"
  kms_key_id  = aws_kms_key.main.arn
}
resource "aws_secretsmanager_secret_version" "main" {
  secret_id     = aws_secretsmanager_secret.main.id
  secret_string = jsonencode({ nodekey = regex("nodeKey\\\":\\\"(\\w+)\\\"", local.network_plugin_secrets_json)[0] })
}
resource "aws_secretsmanager_secret_policy" "main" {
  secret_arn = aws_secretsmanager_secret.main.arn

  policy = <<EOF
{
  "Version" : "2012-10-17",
  "Statement" : [
    {
      "Effect" : "Allow",
      "Principal" : {
        "AWS" : "${aws_iam_role.main.arn}"
      },
      "Action" : ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"],
      "Resource" : "*"
    }
  ]
}
EOF
}

resource "helm_release" "main" {
  depends_on = [
    aws_secretsmanager_secret_version.main
  ]

  name = "qn-0"

  repository = local.https_url_helm_charts_repository
  chart      = "quorum-node"
  version    = var.helm_chart_version

  replace = true
  wait    = true
  timeout = 300

  values = [
    file(local.qn_values_path),
    file(local.qn_info_path),
    file("${local.tmp_folder_path}/deployment.yaml"),
    templatefile("${path.module}/templates/values.yaml.tftpl", { region_name = data.aws_region.main.name }),
    file(local.network_config_values),

    data.local_file.secretsmanager_yaml.content
  ]
}

data "kubernetes_config_map" "main" {
  depends_on = [
    helm_release.main
  ]

  metadata {
    name = "quorum-settings"
  }
}

data "kubernetes_service" "quorum_rpc" {
  depends_on = [
    helm_release.main,
    local_file.github_info_yaml,
  ]

  metadata {
    name = "quorum-rpc"
  }
}

resource "null_resource" "smart_contract" {
  count = fileexists("${var.net_dir_path}/smartContractAbi.json") ? 0 : 1

  depends_on = [
    helm_release.main,
    local_file.genesis_geth_json
  ]

  provisioner "local-exec" {
    command = "helm pl-plugin --smartContract -i ${local.qn_values_path} ${local.gh_info_path} ${path.module}/github.info.yaml ${local.new_network_service} ${local.qn_info_path} ${local.smart_contract_info_path} ${local.tmp_folder_path}/networkName.yaml -o ${local.tmp_folder_path}"
  }
}
