resource "proxmox_virtual_environment_file" "ubuntu_cloud_config" {
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
  - vgcreate openebs-lvm /dev/vdb
EOF

    file_name = "ubuntu-lvm-test-cloud-config.yaml"
  }
}

resource "proxmox_virtual_environment_download_file" "ubuntu_image" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = "node1"
  file_name    = "lvm-test-ubuntu-server-cloudimg-amd64.img"
  url          = var.vm_ubuntu_image_url
}

resource "proxmox_virtual_environment_vm" "lvm-test" {
  name = "lvm-test"
  tags = ["ubuntu", "lvm-test"]

  node_name = "node1"
  vm_id     = 666

  agent {
    enabled = true
  }

  disk {
    datastore_id = "local-lvm"
    file_id      = proxmox_virtual_environment_download_file.ubuntu_image.id
    interface    = "virtio0"
    size         = 20
    discard      = "on"
  }

  disk {
    datastore_id = "sata"
    file_format  = "raw"
    interface    = "virtio1"
    size         = 20
    discard      = "on"
  }

  initialization {
    ip_config {
      ipv4 {
        address = "172.27.1.1/12"
        gateway = "172.16.0.1"
      }
    }

    dns {
      servers = ["172.16.0.2", "172.16.0.1"]
    }

    user_data_file_id = proxmox_virtual_environment_file.ubuntu_cloud_config.id
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

resource "dns_a_record_set" "control_record" {
  zone      = var.dns_zone
  name      = "lvm-test"
  addresses = ["172.27.1.1"]
  ttl       = var.dns_ttl
}
