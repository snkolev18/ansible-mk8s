## Prerequisites

Before running the **mk8s playbook**, ensure that:

You have Ansible installed on your control machine. If not, install it using you have 2 options
 - Python Virtualenv Installation
 - Global Installation

#### Python Virtualenv Installation

```bash
python3 -m venv .venv
.venv/bin/activate
pip3 install ansible
```

#### Global Installation

Note: *You cannot have an Ansible controller on Windows*.  
Reason: https://blog.rolpdog.com/2020/03/why-no-ansible-controller-for-windows.html

Refer to your OS distribution's package manager  
For example, installation on Ubuntu:
```bash
apt update && apt install ansible
```

## Define the Inventory

There is already a boilerplate inventory in the repository, which one should use.  
Adjust the variables to fit your need.

#### Inventory Variables explanation

- [`ansible_ssh_common_args`](https://docs.ansible.com/ansible/latest/reference_appendices/config.html#default-vault-password-file) - Common extra args for all SSH-related tools. For example disabling strict host key checking: `"-o StrictHostKeyChecking=no"`

- [`ansible_user`](https://docs.ansible.com/ansible/latest/reference_appendices/special_variables.html#term-ansible_user) - the user Ansible uses to connect to remote machines
- `ansible_password` - user's password
- [`ansible_python_interpreter`](https://docs.ansible.com/ansible/latest/reference_appendices/python_3_support.html#using-python-3-on-the-managed-machines-with-commands-and-playbooks) - path to the python interpreter on the target machines

- `mk8s_user_username` - username for a machine user, which will be created after the playbook finishes. The user is in a special group called `microk8s` that allows executing kubernetes commands and other commands, which would usually require privilege escalation.
- `mk8s_user_password` - self explanatory
- `mk8s_user_password_salt` - a simple string which will be appended to the password before hashing it. This is required by the Ansible module which manages users ([`user`](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/user_module.html) module). It is advisable to save it as well

#### Inventory Groups explanation

1. `microk8s-nodes` - all **microk8s** installation *candidates*
2. `microk8s-masters` - specifies **master** nodes in the cluster
4. `microk8s-workers` - specifies **worker** nodes in the cluster
3. `microk8s-inviter` - specifies the mk8s node, which will create a cluster invitation for the other nodes (`microk8s-masters`, `microk8s-workers`)

## Running the Playbook

```
ansible-playbook playbook.yml -i inventory.yml
```


### Remarks

[`ansible.cfg`](https://docs.ansible.com/ansible/latest/reference_appendices/config.html) contains a default variable ([`vault_password_file`](https://docs.ansible.com/ansible/latest/reference_appendices/config.html#default-vault-password-file)) that points to a vault password file. It is recommended to encrypt all sensitive information in your playbook using the [`ansible-vault`](https://docs.ansible.com/ansible/latest/cli/ansible-vault.html) utility for example. Define your ansible vault password and use it across
