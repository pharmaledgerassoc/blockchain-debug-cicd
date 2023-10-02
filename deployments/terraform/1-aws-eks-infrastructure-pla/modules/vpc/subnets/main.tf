# --- vpc/subnets/main.tf ---

data "aws_availability_zones" "available" {
  state = "available"
}
