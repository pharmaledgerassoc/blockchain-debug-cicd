# --- bundle-eks-managed-addons/kube-proxy.tf ---

resource "aws_eks_addon" "kube_proxy" {
  cluster_name                = var.eks_cluster_name
  addon_name                  = "kube-proxy"
  addon_version               = var.kube_proxy_version
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
}