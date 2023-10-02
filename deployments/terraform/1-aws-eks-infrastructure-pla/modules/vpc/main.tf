# --- vpc/main.tf ---

data "aws_caller_identity" "main" {}
data "aws_region" "main" {}
data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_eip" "nlb" {
  #checkov:skip=CKV2_AWS_19:Ensure that all EIP addresses allocated to a VPC are attached to EC2 instances

  domain = "vpc"

  tags = {
    Name    = "${var.network_name}-${var.cluster_name}-quorum-node-qn-0-eip"
    Network = var.network_name
    Cluster = var.cluster_name
  }
}

module "subnets" {
  source = "./subnets"

  cluster_name = var.cluster_name
  network_name = var.network_name

  enable_single_natgw = var.enable_single_natgw

  vpc_id             = aws_vpc.main.id
  vpc_cidr_block     = var.vpc_cidr_block
  vpc_endpoint_s3_id = aws_vpc_endpoint.s3.id
  vpc_igw_id         = aws_internet_gateway.main.id
  vpc_natgw_ids      = aws_nat_gateway.main[*].id
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name    = "${var.network_name}-${var.cluster_name}-vpc"
    Network = var.network_name
    Cluster = var.cluster_name
  }
}
resource "aws_default_security_group" "main" {
  vpc_id = aws_vpc.main.id
}

resource "aws_vpc_dhcp_options" "main" {
  ntp_servers         = ["169.254.169.123"]
  domain_name_servers = ["AmazonProvidedDNS"]

  tags = {
    Name    = "${var.network_name}-${var.cluster_name}-vpc-dhcp-option"
    Network = var.network_name
    Cluster = var.cluster_name
  }
}
resource "aws_vpc_dhcp_options_association" "main" {
  vpc_id          = aws_vpc.main.id
  dhcp_options_id = aws_vpc_dhcp_options.main.id
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name    = "${var.network_name}-${var.cluster_name}-igw"
    Network = var.network_name
    Cluster = var.cluster_name
  }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.${data.aws_region.main.name}.s3"

  tags = {
    Name    = "${var.network_name}-${var.cluster_name}-s3-gw-vpc-endpoint"
    Network = var.network_name
    Cluster = var.cluster_name
  }
}

resource "aws_flow_log" "main" {
  iam_role_arn    = aws_iam_role.main.arn
  log_destination = aws_cloudwatch_log_group.main.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.main.id
}
