# --- vpc/outputs.tf ---

output "vpc_id" {
  value = aws_vpc.main.id
}
output "vpc_dhcp_options_id" {
  value = aws_vpc_dhcp_options.main.id
}
output "vpc_igw_id" {
  value = aws_internet_gateway.main.id
}
output "vpc_s3_endpoint_id" {
  value = aws_vpc_endpoint.s3.id
}
output "vpc_cloudwatch_log_group_arn" {
  value = aws_cloudwatch_log_group.main.arn
}

output "kms_arn" {
  value = aws_kms_key.main.arn
}

output "natgw_eip_allocation_ids" {
  value = aws_eip.main[*].allocation_id
}
output "natgw_ids" {
  value = aws_nat_gateway.main[*].id
}

output "subnet_private_eks_controlplane_ids" {
  value = module.subnets.subnet_private_eks_controlplane_ids
}
output "subnet_private_eks_nodegroup_ids" {
  value = module.subnets.subnet_private_eks_nodegroup_ids
}

output "subnet_public_natgw_ids" {
  value = module.subnets.subnet_public_natgw_ids
}
output "subnet_public_alb_ids" {
  value = module.subnets.subnet_public_alb_ids
}
