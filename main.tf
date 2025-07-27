
resource "proxmox_vm_qemu" "gateway" {

  name        = var.VMname
  target_node = "rami"
  clone       = "ubuntu-2004-cloudinit-template"
  full_clone = true
  agent   = 1
  os_type = "cloud-init"
  vmid    = var.VM_ID

  ciuser     = var.ciUser
  cipassword = var.ciPassword
  ipconfig0  = "ip=192.168.1.200/24,gw=192.168.1.250"
  
  # Add VirtIO SCSI controller
  scsihw = "virtio-scsi-pci"

  cores   = var.cpu
  sockets = 1
  memory  = var.ram

  disk {
    type    = "cloudinit"
    storage = "local-lvm"
    size    = var.disk
    slot    = "ide2" 
  }

  disk {
    type    = "disk"
    storage = "local-lvm"
    size    = var.disk
    slot    = "scsi0" 
  }

  network {
    id     = 0
    model  = "virtio"
    bridge = "vmbr0"
  }
   sshkeys = file("~/.ssh/id_rsa.pub")

    serial {
      id = 0
      type = "socket"
    }


  lifecycle {
    ignore_changes = [network]
  }

}

resource "proxmox_vm_qemu" "media" {

  name        = "media-server"
  target_node = "rami"
  clone       = "ubuntu-2004-cloudinit-template"
  full_clone  = false
  agent       = 1
  os_type     = "cloud-init"
  vmid        = 911

  ciuser     = "media"
  cipassword = "media123"
  ipconfig0  = "ip=192.168.1.201/24,gw=192.168.1.250"
  
  scsihw = "virtio-scsi-pci"

  cores   = 2
  sockets = 1
  memory  = 8192

  # Cloud-init disk (for cloud-init config only)
  disk {
    type    = "cloudinit"
    storage = "local-lvm"
    size    = "5G"
    slot    = "ide2"
  }

  # OS and apps disk (20G on local-lvm)
  disk {
    type    = "disk"
    storage = "local-lvm"
    size    = "20G"
    slot    = "scsi0"
  }

  # Media storage disk (3500G on media storage)
  disk {
    type    = "disk"
    storage = "media"
    size    = "3500G"
    slot    = "scsi1"
  }
  # Media storage disk (3500G on media storage)
  disk {
    type    = "disk"
    storage = "media1"
    size    = "3500G"
    slot    = "scsi2"
  }
  network {
    id     = 0
    model  = "virtio"
    bridge = "vmbr0"
  }

  sshkeys = file("~/.ssh/id_rsa.pub")

  serial {
    id   = 0
    type = "socket"
  }

  lifecycle {
    ignore_changes = [disk[0].size]
  }
}



