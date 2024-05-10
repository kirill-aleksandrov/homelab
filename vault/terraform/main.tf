resource "proxmox_virtual_environment_file" "cloud_config" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = "node1"

  source_raw {
    data = <<EOF
#cloud-config
ssh_pwauth: true
users:
  - default
  - name: ${var.vm_username}
    shell: /bin/bash
    lock_passwd: false
    groups:
      - sudo
    passwd: ${var.vm_password_hash}
    sudo: ALL=(ALL) NOPASSWD:ALL
packages:
  - qemu-guest-agent
runcmd:
  - systemctl enable --now qemu-guest-agent
EOF

    file_name = "ubuntu-vault-cloud-config.yaml"
  }
}


resource "proxmox_virtual_environment_download_file" "vault_ubuntu_noble" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = "node1"
  file_name    = "vault-noble-server-cloudimg-amd64.img"
  url          = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
}

resource "proxmox_virtual_environment_vm" "ubuntu_vm" {
  name = "vault"
  tags = ["ubuntu", "noble", "vault"]

  node_name = var.vm_node_name
  vm_id     = var.vm_id

  agent {
    enabled = true
  }

  disk {
    datastore_id = var.vm_datastore_id
    file_id      = proxmox_virtual_environment_download_file.vault_ubuntu_noble.id
    interface    = "scsi0"
    size         = 8
    ssd          = true
    discard      = "on"
  }

  initialization {
    ip_config {
      ipv4 {
        address = var.vm_ipv4_address
        gateway = var.vm_ipv4_gateway
      }
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

resource "dns_a_record_set" "a_record" {
  zone      = var.dns_zone
  name      = "vault"
  // strip subnet mask from vm_ipv4_address
  addresses = [replace(var.vm_ipv4_address, "/\\/\\d{1,2}$/", "")]
  ttl       = var.dns_ttl
}
