# --- 6-epi-app-deployment-pla/kms.tf ---

resource "aws_kms_key" "ethadapter" {
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
            "AWS": "${aws_iam_role.ethadapter.arn}"
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
    Name    = "eks/${var.network_name}-${var.cluster_name}/ethadapter"
    Network = var.network_name
    Cluster = var.cluster_name
  }
}
resource "aws_kms_alias" "ethadapter" {
  name          = "alias/eks/${var.network_name}-${var.cluster_name}/ethadapter"
  target_key_id = aws_kms_key.ethadapter.key_id
}

resource "aws_kms_key" "epi" {
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
            "AWS": "${aws_iam_role.epi.arn}"
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
    Name    = "eks/${var.network_name}-${var.cluster_name}/epi"
    Network = var.network_name
    Cluster = var.cluster_name
  }
}
resource "aws_kms_alias" "epi" {
  name          = "alias/eks/${var.network_name}-${var.cluster_name}/epi"
  target_key_id = aws_kms_key.epi.key_id
}
