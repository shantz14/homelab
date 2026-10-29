locals {
  vms = {
    "k3s-cp1" = { vm_id = 120, ip = "192.168.8.20", cores = 2, memory = 4096, disk = 40 }
    "k3s-w1"  = { vm_id = 121, ip = "192.168.8.21", cores = 6, memory = 16384, disk = 60 }
  }
  gateway_ip = "192.168.8.1"
  node_name = "pve01"
}

# Cloud-init snippet that installs the guest agent on first boot
resource "proxmox_virtual_environment_file" "guest_agent" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = local.node_name

  source_raw {
    file_name = "vendor-guest-agent.yaml"
    data      = <<-EOF
    #cloud-config
    packages:
    - qemu-guest-agent
    runcmd:
    - systemctl enable --now qemu-guest-agent
    EOF
  }
}

resource "proxmox_virtual_environment_vm" "k3s" {
  for_each = local.vms

  name            = each.key
  vm_id           = each.value.vm_id
  node_name       = local.node_name
  tags            = ["k3s", "terraform"]
  on_boot         = true
  stop_on_destroy = true # force stop on destroy, so it doesn't hang if the agent isn't up yet

  clone {
    vm_id = 9000
    full  = true
  }

  agent {
    enabled = true
  }

  cpu {
    cores = each.value.cores
    type  = "host"
  }

  memory {
    dedicated = each.value.memory
  }

  disk {
    datastore_id = "local-lvm"
    interface    = "scsi0"
    size         = each.value.disk
    discard      = "on"
    ssd          = true
    iothread     = true
  }

  network_device {
    bridge = "vmbr0"
  }

  serial_device {}
  vga {
    type = "serial0"
  }

  initialization {
    datastore_id = "local-lvm"
    interface    = "ide0" # i set the template's cloud-init drive to ide0, not the provider's default ide2

    ip_config {
      ipv4 {
        address = "${each.value.ip}/24"
        gateway = local.gateway_ip
      }
    }

    dns {
      domain  = "lab.home"
      servers = [local.gateway_ip]
    }

    user_account {
      username = "isaac"
      keys     = [trimspace(file(pathexpand("~/.ssh/id_ed25519.pub")))]
    }

    vendor_data_file_id = proxmox_virtual_environment_file.guest_agent.id
  }
}

output "vm_ips" {
  value = { for name, vm in local.vms : name => vm.ip }
}
