resource "proxmox_virtual_environment_file" "cloud_config" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = "node1"

  source_raw {
    data = templatefile("${path.module}/cloud-config.tftpl", {
      username : var.vm_username,
      password_hash : var.vm_password_hash
    })
    file_name = "bind9-alpine-cloud-config.yaml"
  }
}

resource "proxmox_virtual_environment_download_file" "image" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = "node1"
  file_name    = "bind9-alpine-cloudimg-amd64.img"
  url          = var.vm_alpine_image_url
}

resource "proxmox_virtual_environment_vm" "vm" {
  name = "bind9"
  tags = ["alpine", "bind9"]

  node_name = "node1"
  vm_id     = 200

  agent {
    enabled = true
  }

  disk {
    datastore_id = "local-lvm"
    file_id      = proxmox_virtual_environment_download_file.image.id
    interface    = "virtio0"
    size         = 2
    discard      = "on"
  }

  initialization {
    ip_config {
      ipv4 {
        address = "172.16.0.2/12"
        gateway = "172.16.0.1"
      }
    }

    dns {
      servers = ["172.16.0.2", "172.16.0.1"]
    }

    user_data_file_id = proxmox_virtual_environment_file.cloud_config.id
  }

  network_device {
    bridge = "vmbr0"
  }

  operating_system {
    type = "l26"
  }

  machine = "q35"
  bios    = "ovmf"

  efi_disk {
    datastore_id = "local-lvm"
    file_format  = "raw"
  }

  cpu {
    cores = 1
    type  = "x86-64-v3"
  }
  memory {
    # Enough memory for cloud-init to finish
    dedicated = 192
  }

  startup {
    order    = 0
    up_delay = 30
  }
}
