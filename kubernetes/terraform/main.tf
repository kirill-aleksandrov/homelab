resource "proxmox_virtual_environment_file" "ubuntu_cloud_control_config" {
  count = 3

  content_type = "snippets"
  datastore_id = "local"
  node_name    = "node${count.index + 1}"

  source_raw {
    data = templatefile("${path.module}/cloud-config.tftpl", {
      create_vg : false,
      username : var.vm_username,
      password_hash : var.vm_password_hash
    })
    file_name = "ubuntu-kubernetes-control-cloud-config.yaml"
  }
}

resource "proxmox_virtual_environment_file" "ubuntu_cloud_node_config" {
  count = 3

  content_type = "snippets"
  datastore_id = "local"
  node_name    = "node${count.index + 1}"

  source_raw {
    data = templatefile("${path.module}/cloud-config.tftpl", {
      create_vg : true,
      username : var.vm_username,
      password_hash : var.vm_password_hash
    })
    file_name = "ubuntu-kubernetes-node-cloud-config.yaml"
  }
}

resource "proxmox_virtual_environment_download_file" "ubuntu_image" {
  count = 3

  content_type = "iso"
  datastore_id = "local"
  node_name    = "node${count.index + 1}"
  file_name    = "kubernetes-ubuntu-server-cloudimg-amd64.img"
  url          = var.vm_ubuntu_image_url
}

resource "proxmox_virtual_environment_vm" "control_ubuntu_vm" {
  count = 3

  name = "kubernetes-control"
  tags = ["ubuntu", "kubernetes"]

  node_name = "node${count.index + 1}"
  vm_id     = var.vm_control_start_id + count.index

  agent {
    enabled = true
  }

  disk {
    datastore_id = "local-lvm"
    file_id      = proxmox_virtual_environment_download_file.ubuntu_image[count.index].id
    interface    = "virtio0"
    size         = 20
    ssd          = true
    discard      = "on"
  }

  initialization {
    ip_config {
      ipv4 {
        address = "172.20.1.${count.index + 1}/12"
        gateway = "172.16.0.1"
      }
    }

    dns {
      servers = ["172.16.0.2", "172.16.0.1"]
    }

    user_data_file_id = proxmox_virtual_environment_file.ubuntu_cloud_control_config[count.index].id
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
    cores = 2
    type  = "x86-64-v3"
  }
  memory {
    dedicated = 2048
  }
}

resource "proxmox_virtual_environment_vm" "node_ubuntu_vm" {
  count = 3

  name = "kubernetes-node"
  tags = ["ubuntu", "kubernetes"]

  node_name = "node${count.index + 1}"
  vm_id     = var.vm_node_start_id + count.index

  agent {
    enabled = true
  }

  disk {
    datastore_id = "local-lvm"
    file_id      = proxmox_virtual_environment_download_file.ubuntu_image[count.index].id
    interface    = "virtio0"
    size         = 60
    ssd          = true
    discard      = "on"
  }

  disk {
    datastore_id = "sata"
    file_format  = "raw"
    interface    = "virtio1"
    size         = 200
    discard      = "on"
  }

  initialization {
    ip_config {
      ipv4 {
        address = "172.20.2.${count.index + 1}/12"
        gateway = "172.16.0.1"
      }
    }

    dns {
      servers = ["172.16.0.2", "172.16.0.1"]
    }

    user_data_file_id = proxmox_virtual_environment_file.ubuntu_cloud_node_config[count.index].id
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
    cores = 6
    type  = "x86-64-v3"
  }
  memory {
    dedicated = 8192
  }
}

resource "dns_a_record_set" "control_record" {
  count = 3

  zone      = var.dns_zone
  name      = "node${count.index + 1}.control.kubernetes"
  addresses = ["172.20.1.${count.index + 1}"]
  ttl       = var.dns_ttl
}

resource "dns_a_record_set" "node_record" {
  count = 3

  zone      = var.dns_zone
  name      = "node${count.index + 1}.node.kubernetes"
  addresses = ["172.20.2.${count.index + 1}"]
  ttl       = var.dns_ttl
}
