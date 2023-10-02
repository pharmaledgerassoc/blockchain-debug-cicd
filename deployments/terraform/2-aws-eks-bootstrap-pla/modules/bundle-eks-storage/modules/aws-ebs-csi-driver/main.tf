# --- bundle-eks-storage/main.tf ---

data "aws_caller_identity" "main" {}

data "aws_kms_key" "main" {
  key_id = "alias/eks/${var.eks_cluster_name}/cluster"
}

resource "aws_kms_key" "ebs_csi_driver" {
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
        "Effect": "Allow",
        "Principal": {
            "AWS": "${aws_iam_role.ebs_csi_driver.arn}"
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
    Name = "eks/${var.eks_cluster_name}/cluster"
  }
}
resource "aws_kms_alias" "ebs_csi_driver" {
  name          = "alias/eks/${var.eks_cluster_name}/ebs-csi-driver"
  target_key_id = aws_kms_key.ebs_csi_driver.key_id
}


resource "aws_iam_role" "ebs_csi_driver" {
  name = "${var.eks_cluster_name}-aws-ebs-csi-controller"

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
            "${trim(var.oidc_provider_url, "https://")}:sub" : "system:serviceaccount:kube-system:ebs-csi-controller-sa",
          }
        }
      },
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  ]

  inline_policy {
    name = "${var.eks_cluster_name}-aws-ebs-csi-driver"

    policy = templatefile("${path.module}/templates/ebs-csi-driver-kms-policy.tpl", { kms_key_arn = data.aws_kms_key.main.arn })
  }
}

resource "aws_eks_addon" "ebs_csi_driver" {
  cluster_name                = var.eks_cluster_name
  addon_name                  = "aws-ebs-csi-driver"
  addon_version               = var.ebs_csi_driver_version
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  service_account_role_arn    = aws_iam_role.ebs_csi_driver.arn
}

resource "kubernetes_storage_class" "main" {
  depends_on = [
    aws_eks_addon.ebs_csi_driver
  ]

  metadata {
    name = "gp3-encrypted"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }

  storage_provisioner    = "ebs.csi.aws.com"
  allow_volume_expansion = true
  parameters = {
    "csi.storage.k8s.io/fstype" = "ext4"
    "type"                      = "gp3"
    "encrypted"                 = "true"
    "kmsKeyId"                  = data.aws_kms_key.main.arn
  }
  reclaim_policy      = "Delete"
  volume_binding_mode = "WaitForFirstConsumer"
}

resource "kubernetes_annotations" "storage_class_gp2" {
  depends_on = [
    kubernetes_storage_class.main
  ]

  api_version = "storage.k8s.io/v1"
  kind        = "StorageClass"
  metadata {
    name = "gp2"
  }
  annotations = {
    "storageclass.kubernetes.io/is-default-class" = "false"
  }

  force = true
}
