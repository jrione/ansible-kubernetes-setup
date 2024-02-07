variable "provnet_name" {}
variable "router_id" {}

variable "float_ip_start" {}
variable "float_ip_end" {}
variable "float_ip_naming" {}

variable "internal_network_name" {}
variable "internal_subnet_name" {}
variable "internal_subnet_cidr" {}

variable "image_id" {}
variable "flavor_id" {}
variable "key_pair" {}
variable "security_group" {}

variable "os_username" {}
variable "os_project_name" {}
variable "os_password" {}
variable "os_auth_url" {}
variable "os_region" {}

locals {
  provnet_subnet      = data.openstack_networking_subnet_v2.provnet-subnet.cidr
  internal_subnet     = openstack_networking_subnet_v2.new-subnet.cidr
  float_ip_segment    = replace(local.provnet_subnet, "0/24", "")
  internal_ip_segment = replace(local.internal_subnet, "0/24", "")
  floating_ip_alloc = {
    for index, i in range(var.float_ip_start, var.float_ip_end) :
    var.float_ip_naming[index] => {
      name     = var.float_ip_naming[index]
      addr     = format("%s%s", local.float_ip_segment, i)
      int_addr = format("%s%s", local.internal_ip_segment, i)
      size     = var.float_ip_naming[index] == "master" ? 30 : 30
      netName  = openstack_networking_network_v2.new-network.name
    }
  }
}

locals {
  ingpo = { for each in local.floating_ip_alloc : each.name => each }
}

