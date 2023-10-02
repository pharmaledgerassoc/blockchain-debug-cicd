# --- 2-aws-eks-bootstrap-pla/modules/aws-for-fluent-bit/main.tf ---

data "aws_region" "main" {}
data "aws_caller_identity" "main" {}

data "aws_kms_key" "main" {
  key_id = "alias/eks/${var.eks_cluster_name}/cluster"
}

resource "aws_cloudwatch_log_group" "main" {
  #checkov:skip=CKV_AWS_338:Ensure CloudWatch log groups retains logs for at least 1 year

  name = "/aws/eks/${var.eks_cluster_name}/containers"

  retention_in_days = 30

  kms_key_id = data.aws_kms_key.main.arn
}

resource "aws_iam_role" "main" {
  name = "${var.eks_cluster_name}-aws-for-fluent-bit"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = local.oidc_provider_arn
        },
        Condition = {
          StringEquals = {
            "${trim(var.oidc_provider_url, "https://")}:aud" : "sts.amazonaws.com"
            "${trim(var.oidc_provider_url, "https://")}:sub" : "system:serviceaccount:kube-system:aws-for-fluent-bit",
          }
        }
      },
    ]
  })

  inline_policy {
    name = "${var.eks_cluster_name}-aws-for-fluent-bit"

    policy = templatefile("${path.module}/files/policy.json", { cloudwatch_log_group_arn = aws_cloudwatch_log_group.main.arn })
  }
}

resource "helm_release" "main" {
  name      = "aws-for-fluent-bit"
  namespace = "kube-system"

  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-for-fluent-bit"
  version    = var.helm_chart_version

  set {
    name  = "image.tag"
    value = var.image_version
  }
  set {
    name  = "serviceAccount.name"
    value = "aws-for-fluent-bit"
  }
  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.main.arn
  }
  set {
    name  = "cloudWatch.enabled"
    value = "false"
  }
  set {
    name  = "cloudWatchLogs.enabled"
    value = "false"
  }
  set {
    name  = "firehose.enabled"
    value = "false"
  }
  set {
    name  = "kinesis.enabled"
    value = "false"
  }
  set {
    name  = "elasticsearch.enabled"
    value = "false"
  }

  values = [<<EOF
annotations:
  prometheus.io/scrape: "true"
  prometheus.io/path: "/api/v1/metrics/prometheus"
  prometheus.io/port: "2020"

service:
  extraService: |
    HTTP_Server  On
    HTTP_Listen  0.0.0.0
    HTTP_PORT    2020
    Health_Check On
    HC_Errors_Count 5 
    HC_Retry_Failure_Count 5 
    HC_Period 5

input:
  tag: "kube.*"
  path: "/var/log/containers/*.log"
  db: "/var/log/flb_kube.db"
  parser: docker
  dockerMode: "On"
  memBufLimit: 5MB
  skipLongLines: "On"
  refreshInterval: 10

filter:
  match: "kube.*"
  kubeURL: "https://kubernetes.default.svc.cluster.local:443"
  mergeLog: "On"
  mergeLogKey: "data"
  keepLog: "On"
  k8sLoggingParser: "On"
  k8sLoggingExclude: "On"

additionalOutputs: |
  [OUTPUT]
      Name              cloudwatch_logs
      Match             kube.*
      region            ${data.aws_region.main.name}
      log_group_name    ${aws_cloudwatch_log_group.main.name}
      log_stream_prefix from-fluent-bit-
      auto_create_group false
EOF
  ]
}
