terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
    }
  }
}

provider "libvirt" {
  uri = var.libvirt_uri
}

# REMNUX
resource "libvirt_volume" "remnuxdisk" {
  name             = "remnux.qcow2"
  base_volume_name = "remnux-base.qcow2"
  pool             = var.pool_name
}

resource "libvirt_domain" "remnux" {
  name        = "remnux"
  description = "remnux instance"
  vcpu        = var.remnux_vcpu_count
  memory      = var.remnux_memory_mb
  running     = true

  disk {
    volume_id = libvirt_volume.remnuxdisk.id
  }

  network_interface {
    network_id = libvirt_network.malnet.id
    addresses  = ["10.0.0.2"]
  }

}

# NETWORK
resource "libvirt_network" "malnet" {
  name      = "malnet"
  addresses = ["10.0.0.0/24"]
  mode      = "none"
  dhcp {
    enabled = true
  }
}
