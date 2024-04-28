packer {
  required_plugins {
    proxmox = {
      version = "~> 1"
      source  = "github.com/hashicorp/proxmox"
    }
    ansible = {
      version = "~> 1"
      source  = "github.com/hashicorp/ansible"
    }
  }
}

source "proxmox-iso" "ubuntu-server-jammy" {
  proxmox_url              = "https://proxmox:8006/api2/json"
  username                 = "packer@pve!packer"
  token                    = "token"
  insecure_skip_tls_verify = true

  node = "node"

  vm_id                = 900
  vm_name              = "ubuntu-server-jammy"
  template_description = "Ubuntu Server Jammy template"
  tags                 = "ubuntu;jammy"

  iso_url          = "https://releases.ubuntu.com/22.04.3/ubuntu-22.04.3-live-server-amd64.iso"
  iso_checksum     = "sha256:a4acfda10b18da50e2ec50ccaf860d7f20b389df8765611142305c0e911d16fd"
  iso_storage_pool = "local"
  iso_download_pve = true

  os      = "l26"
  machine = "q35"
  bios    = "ovmf"
  memory  = "2048"
  efi_config {
    efi_storage_pool = "local-lvm"
  }
  qemu_agent      = true
  scsi_controller = "virtio-scsi-single"
  network_adapters {
    model  = "virtio"
    bridge = "vmbr0"
  }
  disks {
    type         = "virtio"
    disk_size    = "20G"
    storage_pool = "local-lvm"
    discard      = true
    io_thread    = true
  }

  additional_iso_files {
    cd_files         = ["./autoinstall/meta-data", "./autoinstall/user-data"]
    cd_label         = "cidata"
    iso_storage_pool = "local"
    unmount          = true
  }

  boot      = "c"
  boot_wait = "10s"
  boot_command = [
    "<esc><wait>",
    "e<wait>",
    "<down><down><down><end>",
    "<bs><bs><bs><bs><wait>",
    "autoinstall ds=nocloud-net;s=/cidata/ ---<wait>",
    "<f10><wait>"
  ]

  ssh_username            = "packer"
  ssh_password            = "insecure-password"
  unmount_iso             = true
  cloud_init              = true
  cloud_init_storage_pool = "local-lvm"

  ssh_timeout = "15m"
}

build {
  name    = "ubuntu-server-jammy"
  sources = ["source.proxmox-iso.ubuntu-server-jammy"]

  provisioner "ansible" {
    user            = "packer"
    playbook_file   = "./playbook/provision.yml"
    extra_arguments = ["--scp-extra-args", "'-O'"]
  }
}
