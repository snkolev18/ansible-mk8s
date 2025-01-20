#!/bin/bash

terraform init
terraform apply
ansible-inventory -i inventory_template.yml -y --list  > inventory.yml
ansible-playbook -i inventory.yml
