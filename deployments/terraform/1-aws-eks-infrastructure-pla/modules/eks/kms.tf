# --- eks/kms.tf ---

resource "aws_kms_key" "main" {
  enable_key_rotation = true

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Effect": "Allow",
        "Principal": {
            "AWS": "arn:aws:iam::${data.aws_caller_identity.main.account_id}:root"
        },
        "Action": "kms:*",
        "Resource": "*"
    },
    {
        "Effect": "Allow",
        "Principal": {
            "AWS": "arn:aws:iam::${data.aws_caller_identity.main.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
        },
        "Action": [
            "kms:Encrypt*",
            "kms:Decrypt*",
            "kms:ReEncrypt*",
            "kms:GenerateDataKey*",
            "kms:Describe*"
        ],
        "Resource": "*"
    },
    {
        "Effect": "Allow",
        "Principal": {
            "AWS": "arn:aws:iam::${data.aws_caller_identity.main.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
        },
        "Action": [
            "kms:CreateGrant"
        ],
        "Resource": "*",
        "Condition": {
          "Bool": {
              "kms:GrantIsForAWSResource": true
          }
        }
    },
    {
        "Effect": "Allow",
        "Principal": {
            "Service": "logs.${data.aws_region.main.name}.amazonaws.com"
        },
        "Action": [
            "kms:Encrypt*",
            "kms:Decrypt*",
            "kms:ReEncrypt*",
            "kms:GenerateDataKey*",
            "kms:Describe*"
        ],
        "Resource": "*",
        "Condition": {
            "ArnEquals": {
                "kms:EncryptionContext:aws:logs:arn": "arn:aws:logs:${data.aws_region.main.name}:${data.aws_caller_identity.main.account_id}:log-group:/aws/eks/${var.network_name}-${var.cluster_name}/cluster"
            }
        }
    },
    {
        "Effect": "Allow",
        "Principal": {
          "Service": "logs.${data.aws_region.main.name}.amazonaws.com"
        },
        "Action": [
          "kms:Encrypt*",
          "kms:Decrypt*",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:Describe*"
        ],
        "Resource": "*",
        "Condition": {
          "ArnEquals": {
            "kms:EncryptionContext:aws:logs:arn" : "arn:aws:logs:${data.aws_region.main.name}:${data.aws_caller_identity.main.account_id}:log-group:/aws/eks/${var.network_name}-${var.cluster_name}/containers"
          }
        }
    }
  ]
}
EOF
  tags = {
    Name    = "eks/${var.network_name}-${var.cluster_name}/cluster"
    Network = var.network_name
    Cluster = var.cluster_name
  }
}
resource "aws_kms_alias" "main" {
  name          = "alias/eks/${var.network_name}-${var.cluster_name}/cluster"
  target_key_id = aws_kms_key.main.key_id
}
