# --- 6-epi-app-deployment-pla/main.tf ---

data "aws_region" "main" {}
data "aws_caller_identity" "main" {}

data "aws_eks_cluster" "main" {
  name = "${var.network_name}-${var.cluster_name}"
}
