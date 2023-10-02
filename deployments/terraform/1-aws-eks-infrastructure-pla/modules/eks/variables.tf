# --- eks/variables.tf ---

variable "network_name" {
  type = string
}
variable "cluster_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "cluster_version" {
  type = string
}

variable "subnet_controlplane_ids" {
  type = list(string)
}
variable "subnet_nodes_ids" {
  type = list(string)
}

variable "instance_type" {
  type    = string
  default = "t3.xlarge"
}

variable "auth_users" {
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}
variable "auth_roles" {
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}
variable "auth_accounts" {
  type    = list(string)
  default = []
}
