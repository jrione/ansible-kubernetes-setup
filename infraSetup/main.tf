data "openstack_networking_network_v2" "provnet"{
  name = var.provnet_name
}

data "openstack_networking_subnet_v2" "provnet-subnet" {
  subnet_id = data.openstack_networking_network_v2.provnet.subnets[0]
}

resource "openstack_networking_network_v2" "new-network" {
    name            = var.internal_network_name
    admin_state_up  = "true"
}

resource "openstack_networking_subnet_v2" "new-subnet" {
    name            = var.internal_subnet_name
    network_id      = openstack_networking_network_v2.new-network.id
    cidr            = var.internal_subnet_cidr
    ip_version      = 4
    dns_nameservers = ["8.8.8.8","1.1.1.1"]
}

resource "openstack_networking_router_interface_v2" "attach-to-router"{
    router_id   = var.router_id
    subnet_id   = openstack_networking_subnet_v2.new-subnet.id
}

resource "openstack_compute_instance_v2" "instance" {
  for_each        = { for each in local.floating_ip_alloc: each.name => each }
  name            = each.value.name
  image_id        = var.image_id
  flavor_id       = var.flavor_id
  key_pair        = var.key_pair
  security_groups = var.security_group

  network {
    name        = each.value.netName
    fixed_ip_v4 = each.value.int_addr
  }

  block_device {
    uuid                  = var.image_id
    source_type           = "image"
    volume_size           = each.value.size
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = true
  }

}

resource "openstack_networking_floatingip_v2" "new-floating-ip"{
  for_each  = { for each in local.floating_ip_alloc: each.name => each }
  pool      = var.provnet_name
  address   = each.value.addr
}

resource "openstack_compute_floatingip_associate_v2" "fip-master-associate" { 
  for_each    = { for each in local.floating_ip_alloc: each.name => each }
  floating_ip = each.value.addr
  instance_id = openstack_compute_instance_v2.instance[each.value.name].id
}