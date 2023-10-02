# --- vpc/natgw.tf ---

resource "aws_eip" "main" {
  #checkov:skip=CKV2_AWS_19:Ensure that all EIP addresses allocated to a VPC are attached to EC2 instances

  count = var.enable_single_natgw ? 1 : length(data.aws_availability_zones.available.names)

  domain = "vpc"

  tags = {
    Name    = var.enable_single_natgw ? "${var.network_name}-${var.cluster_name}-natgw-eip" : "${var.network_name}-${var.cluster_name}-natgw-eip-${substr(data.aws_availability_zones.available.names[count.index], -2, -1)}"
    Network = var.network_name
    Cluster = var.cluster_name
  }
}

resource "aws_nat_gateway" "main" {
  count = var.enable_single_natgw ? 1 : length(data.aws_availability_zones.available.names)

  depends_on = [
    aws_internet_gateway.main
  ]

  allocation_id = aws_eip.main[count.index].id
  subnet_id     = module.subnets.subnet_public_natgw_ids[count.index]

  tags = {
    Name    = var.enable_single_natgw ? "${var.network_name}-${var.cluster_name}-natgw" : "${var.network_name}-${var.cluster_name}-natgw-${substr(data.aws_availability_zones.available.names[count.index], -2, -1)}"
    Network = var.network_name
    Cluster = var.cluster_name
  }
}
