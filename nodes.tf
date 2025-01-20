# Adjust VM attributes to fit in your environment

variable "nodes" {
  description = "Node VM attributes"

  nullable = false
  type = list(object(
    {
      name = string
      node_station = object({
        clone_name        = string
        cores             = number
        sockets           = number
        memory            = number
        address_cidr      = string
        address           = string
        if_name           = string
        dns_server        = string
        gateway           = string
        metallb_ip_ranges = string
      })
    }
  )
  )
  default = [
    {
      name = "microk8s-node1",
      node_station = {
        clone_name        = "ubuntu-server-noble"
        cores             = 4
        sockets           = 1
        memory            = 8192
        address_cidr      = "192.168.1.50/24"
        address           = "192.168.1.50"
        if_name           = "<pve-virt-if>"
        dns_server        = "192.168.1.1"
        gateway           = "192.168.1.1"
        metallb_ip_ranges = "192.168.1.60-192.168.1.69"
      }
    },
    {
      name = "microk8s-node2",
      node_station = {
        clone_name        = "ubuntu-server-noble"
        cores             = 4
        sockets           = 1
        memory            = 8192
        address_cidr      = "192.168.1.51/24"
        address           = "192.168.1.51"
        if_name           = "<pve-virt-if>"
        dns_server        = "192.168.1.1"
        gateway           = "192.168.1.1"
        metallb_ip_ranges = "192.168.1.70-192.168.1.79"
      }
    }
  ]
}
