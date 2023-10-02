# --- vpc/subnets/outputs.tf ---

output "subnet_private_eks_controlplane_ids" {
  value = aws_subnet.private_eks_controlplane[*].id
}

output "subnet_private_eks_nodegroup_ids" {
  value = aws_subnet.private_eks_nodegroup[*].id
}

output "subnet_public_natgw_ids" {
  value = aws_subnet.public_natgw[*].id
}

output "subnet_public_alb_ids" {
  value = aws_subnet.public_alb[*].id
}
