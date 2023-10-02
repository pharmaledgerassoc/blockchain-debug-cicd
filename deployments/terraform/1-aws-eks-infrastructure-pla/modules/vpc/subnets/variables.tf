# --- vpc/subnets/variables.tf ---

variable "network_name" {
  type = string
}
variable "cluster_name" {
  type = string
}

variable "enable_single_natgw" {
  type = bool
}

variable "vpc_id" {
  type = string
}
variable "vpc_cidr_block" {
  type = string
}
variable "vpc_endpoint_s3_id" {
  type = string
}
variable "vpc_igw_id" {
  type = string
}
variable "vpc_natgw_ids" {
  type = list(string)
}
