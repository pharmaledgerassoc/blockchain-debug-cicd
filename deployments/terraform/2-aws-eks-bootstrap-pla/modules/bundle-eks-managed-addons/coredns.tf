# --- bundle-eks-managed-addons/coredns.tf ---

resource "aws_eks_addon" "coredns" {
  cluster_name                = var.eks_cluster_name
  addon_name                  = "coredns"
  addon_version               = var.coredns_version
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
}
