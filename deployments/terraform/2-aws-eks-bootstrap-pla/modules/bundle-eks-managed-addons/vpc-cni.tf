# --- bundle-eks-managed-addons/vpc-cni.tf ---

resource "aws_iam_role" "vpc_cni" {
  name = "${var.eks_cluster_name}-aws-vpc-cni"

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
            "${trim(var.oidc_provider_url, "https://")}:sub" : "system:serviceaccount:kube-system:aws-node",
          }
        }
      },
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  ]
}

resource "aws_eks_addon" "vpc_cni" {
  cluster_name                = var.eks_cluster_name
  addon_name                  = "vpc-cni"
  addon_version               = var.vpc_cni_version
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  service_account_role_arn    = aws_iam_role.vpc_cni.arn
}
