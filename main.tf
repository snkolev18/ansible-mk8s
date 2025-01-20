terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.1-rc1"
    }
    ansible = {
      source  = "ansible/ansible"
      version = "1.3.0"
    }
  }
}

provider "ansible" {
  # Configuration options
}

provider "proxmox" {
  pm_tls_insecure = true
  pm_api_url      = "<proxmox api endpoint>"
  pm_user         = "<proxmox-user>"
  pm_password     = "<proxmox-user-password>"
}

resource "proxmox_cloud_init_disk" "cidisk" {
  for_each = {for name, node_station in var.nodes : name => node_station}

  name     = each.value.name
  pve_node = "<your-pve-node-here>"
  storage  = "local"

  meta_data = yamlencode({
    instance_id = sha1(each.value.name)
    local-hostname = each.value.name
  })

  user_data = <<-EOT
  autoinstall:
  version: 1
  hostname: ${each.value.name}
  locale: en_US
  keyboard:
    layout: us
  ssh:
    install-server: true
    allow-pw: true
    disable_root: true
    ssh_quiet_keygen: true
    allow_public_ssh_keys: true
  packages:
    - apt-transport-https
    - qemu-guest-agent
    - sudo
  storage:
    layout:
      name: direct
    swap:
      size: 0
  user-data:
    package_upgrade: true
    timezone: Europe/Sofia
    users:
      - name: user
        groups: [adm, sudo]
        lock-passwd: false
        sudo: ALL=(ALL) NOPASSWD:ALL
        shell: /bin/bash
        passwd: 
  EOT

  network_config = yamlencode({
    version = 1
    config = [
      {
        type = "physical"
        name = each.value.node_station.if_name
        subnets = [
          {
            type    = "static"
            address = each.value.node_station.address_cidr
            gateway = each.value.node_station.gateway
            dns_nameservers = [
              each.value.node_station.dns_server
            ]
          }
        ]
      }
    ]
  })
}

resource "proxmox_vm_qemu" "microk8s_nodes" {
  target_node = "<pve node>"
  full_clone  = false
  clone_wait  = 20

  for_each = {for name, node_station in var.nodes : name => node_station}

  name    = each.value.name
  clone   = each.value.node_station.clone_name
  memory  = each.value.node_station.memory
  cores   = each.value.node_station.cores
  sockets = each.value.node_station.sockets
  vmid    = 4000 + (index(var.nodes, each.value) + 1)
  qemu_os = "l26"
  agent   = 1
  desc    = "Ubuntu Server Noble Image"

  disks {
    virtio {
      virtio0 {
        disk {
          size    = 80
          storage = "<pve storage pool name>"
        }
      }
    }
    ide {
      ide0 {
        cdrom {
          iso = proxmox_cloud_init_disk.cidisk[each.key].id
        }
      }
    }
  }

  network {
    bridge    = "<bridge interface, if applicable>"
    firewall  = true
    link_down = false
    model     = "virtio"
  }
}

resource "ansible_host" "microk8s_nodes" {

  for_each = {
    for name, node_station in var.nodes :
    name => node_station
  }

  name = each.value.name

  variables = {
    ansible_host               = each.value.node_station.address
    ansible_user               = "",
    ansible_password           = "",
    ansible_python_interpreter = "/usr/bin/python3",
    metallb_ip_ranges          = each.value.node_station.metallb_ip_ranges
  }
}