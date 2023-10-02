# --- aws-loadbalancer-controller/main.tf ---

data "aws_caller_identity" "main" {}
data "aws_region" "main" {}

resource "aws_iam_role" "main" {
  name = "${var.eks_cluster_name}-aws-load-balancer-controller"

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
            "${trim(var.oidc_provider_url, "https://")}:sub" : "system:serviceaccount:kube-system:aws-load-balancer-controller",
          }
        }
      },
    ]
  })

  inline_policy {
    name = "${var.eks_cluster_name}-aws-load-balancer-controller"

    policy = file("${path.module}/files/policy.json")
  }
}

resource "helm_release" "main" {
  name      = "aws-load-balancer-controller"
  namespace = "kube-system"

  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = var.helm_chart_version

  values = [templatefile("${path.module}/templates/helm_chart_values.tpl", { image_version = var.image_version, cluster_name = var.eks_cluster_name, role_arn = aws_iam_role.main.arn, region_name = data.aws_region.main.name, vpc_id = var.vpc_id })]
}
