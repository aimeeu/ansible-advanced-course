# Ansible Advanced Course

This project demonstrates advanced infrastructure automation patterns using Terraform and Ansible with Multipass virtual machines. It's designed as a learning resource for the Udemy Ansible Advanced Course.

## Overview

The project provisions Ubuntu virtual machines using Multipass and manages them with Ansible through Terraform's native Ansible provider. It showcases infrastructure-as-code best practices, modular design, and dynamic inventory management.

## Architecture

### Infrastructure Components

- **Terraform**: Infrastructure provisioning and orchestration
- **Multipass**: Lightweight VM management (Ubuntu 24.04)
- **Ansible**: Configuration management and automation
- **Cloud-init**: Initial VM configuration and SSH setup

## Project Structure

```
ansible-advanced-course/
├── main.tf                          # Main Terraform configuration
├── ansible.cfg                      # Ansible configuration
├── inventory.yaml                   # Dynamic inventory plugin config
├── ansible/                         # Ansible playbooks directory
├── shared/
│   └── terraform/
│       ├── inventory.tmpl           # Ansible inventory template
│       ├── multipass-compute/       # VM provisioning module
│       │   ├── provider.tf          # Terraform provider configuration
│       │   ├── variable.tf          # Module input variables
│       │   ├── instance.tf          # VM resource definitions
│       │   ├── output.tf            # Module outputs
│       │   ├── ansible.tf           # Ansible provider resources
│       │   └── files/
│       │       └── cloudinit.yaml.tpl  # Cloud-init template
│       └── ansible-provision/       # Ansible playbook execution module
│           ├── ansible.tf           # Playbook provisioner
│           └── variable.tf          # Module variables
```

## Key Files

### Root Configuration

#### [`main.tf`](main.tf)
Main Terraform configuration that:
- Provisions 2 server instances using the `multipass-compute` module
- Generates Ansible inventory file from VM data
- Outputs SSH connection commands

#### [`ansible.cfg`](ansible.cfg)
Ansible configuration with:
- Disabled host key checking for lab environments
- Auto-detection of Python interpreter

#### [`inventory.yaml`](inventory.yaml)
Dynamic inventory configuration using the `cloud.terraform.terraform_provider` plugin

### Shared Modules

#### `multipass-compute` Module
Reusable module for creating Multipass VMs with Ansible integration.

**Files:**
- [`provider.tf`](shared/terraform/multipass-compute/provider.tf): Configures Multipass and Ansible providers
- [`variable.tf`](shared/terraform/multipass-compute/variable.tf): Defines configurable parameters (CPUs, memory, disk, SSH keys)
- [`instance.tf`](shared/terraform/multipass-compute/instance.tf): Creates VMs with random ID suffixes and cloud-init
- [`output.tf`](shared/terraform/multipass-compute/output.tf): Exports instance IPs, names, and SSH keys
- [`ansible.tf`](shared/terraform/multipass-compute/ansible.tf): Manages Ansible groups and hosts via Terraform
- [`files/cloudinit.yaml.tpl`](shared/terraform/multipass-compute/files/cloudinit.yaml.tpl): Cloud-init template for SSH configuration

#### `ansible-provision` Module
Module for executing Ansible playbooks via Terraform.

**Files:**
- [`ansible.tf`](shared/terraform/ansible-provision/ansible.tf): Null resource with local-exec provisioner
- [`variable.tf`](shared/terraform/ansible-provision/variable.tf): Inventory and playbook path variables

### Templates

#### [`shared/terraform/inventory.tmpl`](shared/terraform/inventory.tmpl)
Ansible inventory template that generates INI-format inventory with:
- `[all:vars]` section for global variables
- `[servers]` group for server instances
- `[clients]` group for client instances

## Usage

### Prerequisites

- Terraform >= 1.0
- Multipass installed and running
- Ansible installed
- SSH key pair at `~/.ssh/id_rsa` and `~/.ssh/id_rsa.pub`

### Provisioning Infrastructure

1. Initialize Terraform:
```bash
terraform init
```

2. Review the plan:
```bash
terraform plan
```

3. Apply the configuration:
```bash
terraform apply
```

4. View SSH connection commands:
```bash
terraform output details
```

### Configuration Options

The `multipass-compute` module accepts these variables:

- `instance_count`: Number of VMs to create (default: 2)
- `instance_cpus`: CPU cores per VM (default: 4)
- `instance_memory`: Memory per VM (default: 4GiB)
- `instance_disk`: Disk size per VM (default: 15GiB)
- `instance_image`: Ubuntu image version (default: 24.04)
- `instance_name_prefix`: Prefix for VM names (default: instance)
- `instance_ssh_key`: SSH public key for access (required)
- `ansible_group_name`: Ansible inventory group name (default: default)
- `ansible_user`: SSH user for Ansible (default: ubuntu)

### Generated Files

After applying, Terraform generates:

- `./ansible/inventory.ini`: Ansible inventory with all provisioned VMs
- `shared/terraform/multipass-compute/generated_cloudinit.yaml`: Cloud-init configuration

## Features

### Dynamic Inventory Management
- Terraform Ansible provider creates inventory resources
- Template-based inventory generation
- Support for cloud.terraform plugin

### Modular Design
- Reusable VM provisioning module
- Separate playbook execution module
- Configurable via variables

### Security
- SSH key-based authentication
- Cloud-init for secure initial setup
- Sudo access without password for automation

### Scalability
- Easily adjust instance count
- Resource specifications per module
- Random ID suffixes prevent naming conflicts

## Learning Objectives

This project demonstrates:

1. **Infrastructure as Code**: Declarative VM provisioning
2. **Module Design**: Reusable Terraform components
3. **Dynamic Inventory**: Automated Ansible inventory generation
4. **Cloud-init**: VM initialization and configuration
5. **Provider Integration**: Terraform + Ansible workflow
6. **Template Usage**: Dynamic file generation

## Cleanup

To destroy all resources:

```bash
terraform destroy
```

This will remove all Multipass VMs and generated files.

## License

See [LICENSE](LICENSE) file for details.
