# --- vpc/subnets/private_eks_nodegroup.tf ---

resource "aws_route_table" "private_eks_nodegroup" {
  count = var.enable_single_natgw ? 1 : length(data.aws_availability_zones.available.names)

  vpc_id = var.vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = var.vpc_natgw_ids[count.index]
  }

  tags = {
    Name    = var.enable_single_natgw ? "${var.network_name}-${var.cluster_name}-private-eks-nodegroup-subnet" : "${var.network_name}-${var.cluster_name}-private-eks-nodegroup-${substr(data.aws_availability_zones.available.names[count.index], -2, -1)}"
    Network = var.network_name
    Cluster = var.cluster_name
  }
}

resource "aws_subnet" "private_eks_nodegroup" {
  depends_on = [
    aws_route_table.private_eks_nodegroup
  ]

  count = length(data.aws_availability_zones.available.names)

  vpc_id            = var.vpc_id
  cidr_block        = cidrsubnet(var.vpc_cidr_block, 8, 96 + count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name    = "${var.network_name}-${var.cluster_name}-private-eks-nodegroup-subnet-${substr(data.aws_availability_zones.available.names[count.index], -2, -1)}"
    Network = var.network_name
    Cluster = var.cluster_name

    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}

resource "aws_route_table_association" "private_eks_nodegroup" {
  count = length(data.aws_availability_zones.available.names)

  subnet_id      = aws_subnet.private_eks_nodegroup[count.index].id
  route_table_id = var.enable_single_natgw ? aws_route_table.private_eks_nodegroup[0].id : aws_route_table.private_eks_nodegroup[count.index].id
}

resource "aws_vpc_endpoint_route_table_association" "private_eks_nodegroup" {
  count = var.enable_single_natgw ? 1 : length(data.aws_availability_zones.available.names)

  route_table_id  = var.enable_single_natgw ? aws_route_table.private_eks_nodegroup[0].id : aws_route_table.private_eks_nodegroup[count.index].id
  vpc_endpoint_id = var.vpc_endpoint_s3_id
}
