# --- 4-quorum-node-pla/kms.tf ---

resource "aws_kms_key" "main" {
  enable_key_rotation = true

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Sid": "Enable IAM User Permissions",
        "Effect": "Allow",
        "Principal": {
            "AWS": "arn:aws:iam::${data.aws_caller_identity.main.account_id}:root"
        },
        "Action": "kms:*",
        "Resource": "*"
    },
    {
        "Sid": "Enable IAM User Permissions",
        "Effect": "Allow",
        "Principal": {
            "AWS": "${aws_iam_role.main.arn}"
        },
        "Action": [
            "kms:Encrypt*",
            "kms:Decrypt*",
            "kms:ReEncrypt*",
            "kms:GenerateDataKey*",
            "kms:Describe*"
        ],
        "Resource": "*"
    }
  ]
}
EOF

  tags = {
    Name    = "eks/${var.network_name}-${var.cluster_name}/quorum-node"
    Network = var.network_name
    Cluster = var.cluster_name
  }
}
resource "aws_kms_alias" "main" {
  name          = "alias/eks/${var.network_name}-${var.cluster_name}/quorum-node"
  target_key_id = aws_kms_key.main.key_id
}
