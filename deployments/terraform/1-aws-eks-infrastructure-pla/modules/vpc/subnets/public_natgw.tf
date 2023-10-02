# --- vpc/subnets/public_natgw.tf ---

resource "aws_route_table" "public_natgw" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.vpc_igw_id
  }

  tags = {
    Name    = "${var.network_name}-${var.cluster_name}-public-natgw-route-table"
    Network = var.network_name
    Cluster = var.cluster_name
  }
}
resource "aws_vpc_endpoint_route_table_association" "public_natgw" {
  route_table_id  = aws_route_table.public_natgw.id
  vpc_endpoint_id = var.vpc_endpoint_s3_id
}

resource "aws_subnet" "public_natgw" {
  depends_on = [
    aws_route_table.public_natgw
  ]

  count = length(data.aws_availability_zones.available.names)

  vpc_id            = var.vpc_id
  cidr_block        = cidrsubnet(var.vpc_cidr_block, 8, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  map_public_ip_on_launch = false

  tags = {
    Name    = "${var.network_name}-${var.cluster_name}-public-natgw-subnet-${substr(data.aws_availability_zones.available.names[count.index], -2, -1)}"
    Network = var.network_name
    Cluster = var.cluster_name
  }
}
resource "aws_route_table_association" "public_natgw" {
  count = length(data.aws_availability_zones.available.names)

  subnet_id      = aws_subnet.public_natgw[count.index].id
  route_table_id = aws_route_table.public_natgw.id
}
