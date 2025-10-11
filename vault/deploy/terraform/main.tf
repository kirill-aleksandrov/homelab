resource "proxmox_virtual_environment_file" "ubuntu_cloud_config" {
  count = 3

  content_type = "snippets"
  datastore_id = var.vm_snippet_datastore_id
  node_name    = var.vm_nodes[count.index]

  source_raw {
    data = templatefile("${path.module}/cloud-config.tftpl", {
      username : var.vm_username,
      password_hash : var.vm_password_hash
    })
    file_name = "vault-ubuntu-cloud-config.yaml"
  }
}


resource "proxmox_virtual_environment_download_file" "vault_ubuntu_image" {
  count = 3

  content_type = "iso"
  datastore_id = var.vm_image_datastore_id
  node_name    = var.vm_nodes[count.index]
  file_name    = "vault-ubuntu-server-cloudimg-amd64.img"
  url          = var.vm_ubuntu_image_url
  overwrite    = false
}

resource "proxmox_virtual_environment_vm" "ubuntu_vm" {
  count = length(var.vm_nodes)

  name = "vault"
  tags = ["ubuntu", "vault"]

  node_name = var.vm_nodes[count.index]
  vm_id     = var.vm_start_id + count.index

  agent {
    enabled = true
  }

  disk {
    datastore_id = var.vm_datastore_id
    file_id      = proxmox_virtual_environment_download_file.vault_ubuntu_image[count.index].id
    interface    = "virtio0"
    size         = 20
    ssd          = true
    discard      = "on"
  }

  initialization {
    ip_config {
      ipv4 {
        address = "172.18.1.${count.index + 1}/12"
        gateway = "172.16.0.1"
      }
    }

    dns {
      servers = ["172.16.0.2", "172.16.0.1"]
    }

    user_data_file_id = proxmox_virtual_environment_file.ubuntu_cloud_config[count.index].id
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
    datastore_id = var.vm_datastore_id
    file_format  = "raw"
  }

  cpu {
    cores = 2
    type  = "x86-64-v3"
  }
  memory {
    dedicated = 1024
  }
}

resource "dns_a_record_set" "node_record" {
  count = 3

  zone      = var.dns_zone
  name      = "${var.vm_nodes[count.index]}.vault"
  addresses = ["172.18.1.${count.index + 1}"]
  ttl       = var.dns_ttl
}

resource "dns_a_record_set" "vip_record" {
  zone      = var.dns_zone
  name      = "vault"
  addresses = ["172.18.1.254"]
  ttl       = var.dns_ttl
}
