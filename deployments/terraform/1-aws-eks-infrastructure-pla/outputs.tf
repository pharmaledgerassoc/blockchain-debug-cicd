# --- 1-aws-eks-infrastructure-pla/outputs.tf ---

output "vpc" {
  value = [for x in module.vpc[*] : x]
}
