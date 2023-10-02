# --- 4-quorum-node-pla/iam.tf ---

resource "aws_iam_role" "main" {
  name = "${var.network_name}-${var.cluster_name}-quorum-node-role"

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
            "${trim(data.aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://")}:aud" : "sts.amazonaws.com"
            "${trim(data.aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://")}:sub" : "system:serviceaccount:default:quorum",
          }
        }
      },
    ]
  })

  inline_policy {
    name = "${var.network_name}-${var.cluster_name}-quorum-node-policy"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect   = "Allow"
          Action   = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"]
          Resource = ["arn:aws:secretsmanager:${data.aws_region.main.name}:${data.aws_caller_identity.main.account_id}:secret:${var.network_name}-${var.cluster_name}-quorum-node*"]
        },
        {
          Effect   = "Allow"
          Action   = ["kms:GenerateDataKey", "kms:Decrypt"]
          Resource = ["*"]
        }
      ]
    })
  }
}
