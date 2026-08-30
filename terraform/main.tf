data "vsphere_datacenter" "dc" {
  name = "DC-HOMELAB"
}

data "vsphere_datastore" "datastore" {
  name          = "ESXI-DATASTORE"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = "VM Network"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_host" "esxi" {
  name          = "192.168.1.219"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
  name          = "rhel8-template"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "windows_template" {
  name          = "windows-template"
  datacenter_id = data.vsphere_datacenter.dc.id

}

data "vsphere_resource_pool" "pool" {
  name          = "192.168.1.219/Resources"
  datacenter_id = data.vsphere_datacenter.dc.id
}

locals {
  virtual_machines = {
    web01 = {
      ip     = "192.168.1.101"
      cpu    = 2
      memory = 4096
    }

    web02 = {
      ip     = "192.168.1.102"
      cpu    = 2
      memory = 4096
    }

    app01 = {
      ip     = "192.168.1.103"
      cpu    = 2
      memory = 4096
    }

    db01 = {
      ip     = "192.168.1.104"
      cpu    = 2
      memory = 4096
    }

    lb01 = {
      ip     = "192.168.1.105"
      cpu    = 2
      memory = 2048
    }
  }
}


resource "vsphere_virtual_machine" "linux_vms" {
  for_each = local.virtual_machines

  name             = each.key
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id
  host_system_id   = data.vsphere_host.esxi.id

  num_cpus = each.value.cpu
  memory   = each.value.memory
  guest_id = data.vsphere_virtual_machine.template.guest_id
  firmware = "efi"

  scsi_type = data.vsphere_virtual_machine.template.scsi_type

  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }

  disk {
    label            = "disk0"
    size             = data.vsphere_virtual_machine.template.disks[0].size
    eagerly_scrub    = data.vsphere_virtual_machine.template.disks[0].eagerly_scrub
    thin_provisioned = data.vsphere_virtual_machine.template.disks[0].thin_provisioned
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    customize {
      linux_options {
        host_name = each.key
        domain    = "local"
      }

      network_interface {
        ipv4_address = each.value.ip
        ipv4_netmask = 24
      }

      ipv4_gateway    = "192.168.1.1"
      dns_server_list = ["192.168.1.1"]
    }
  }
}


resource "vsphere_virtual_machine" "dc01" {
  name             = "dc01"
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id
  host_system_id   = data.vsphere_host.esxi.id

  num_cpus = 2
  memory   = 4096
  guest_id = data.vsphere_virtual_machine.windows_template.guest_id
  firmware = "efi"

  scsi_type = data.vsphere_virtual_machine.windows_template.scsi_type

  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.windows_template.network_interface_types[0]
  }

  disk {
    label            = "disk0"
    size             = data.vsphere_virtual_machine.windows_template.disks[0].size
    eagerly_scrub    = data.vsphere_virtual_machine.windows_template.disks[0].eagerly_scrub
    thin_provisioned = data.vsphere_virtual_machine.windows_template.disks[0].thin_provisioned
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.windows_template.id

    customize {
      windows_options {
        computer_name  = "dc01"
        admin_password = var.windows_admin_password
      }

      network_interface {
        ipv4_address = "192.168.1.110"
        ipv4_netmask = 24
      }

      ipv4_gateway    = "192.168.1.1"
      dns_server_list = ["192.168.1.1"]
    }
  }
}
