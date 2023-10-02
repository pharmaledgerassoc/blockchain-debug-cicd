# --- bundle-eks-managed-addons/variables.tf ---

variable "eks_cluster_name" {
  type = string
}
variable "oidc_provider_url" {
  type = string
}

# https://docs.aws.amazon.com/eks/latest/userguide/managing-vpc-cni.html
variable "vpc_cni_version" {
  type = string
}

# https://docs.aws.amazon.com/eks/latest/userguide/managing-kube-proxy.html
variable "kube_proxy_version" {
  type = string
}

# https://docs.aws.amazon.com/eks/latest/userguide/managing-coredns.html
variable "coredns_version" {
  type = string
}
