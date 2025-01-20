Ansible Playbook for MicroK8S with Terraform configs to dynamically create and provision Ubuntu Noble VMs in your Proxmox environment, which will then be used as k8s nodes

### Playing

Playbook can be run with the `buildme.sh` script, which executes the Terraform declarations, then it creates the Ansible inventory, filled with the appropriate variables for each mk8s node

One can also just create the inventory manually and run the playbook
