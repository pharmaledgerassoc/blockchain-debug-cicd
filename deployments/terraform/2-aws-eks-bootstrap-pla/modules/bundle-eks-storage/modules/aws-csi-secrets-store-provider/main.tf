# --- aws-csi-secrets-store-provider/main.tf ---

resource "helm_release" "main" {
  name      = "aws-csi-secrets-store-provider"
  namespace = "kube-system"

  repository = "https://aws.github.io/eks-charts"
  chart      = "csi-secrets-store-provider-aws"
  version    = var.helm_chart_version

  values = [templatefile("${path.module}/templates/helm_chart_values.tpl", { image_version = var.image_version })]
}
