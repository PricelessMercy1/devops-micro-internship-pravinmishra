# EpicBook: Terraform + Ansible Roles (Azure)

Week 09 Assignment 05, DevOps Micro Internship (DMI), Cohort 3.

Terraform provisions the infrastructure. Ansible roles configure the VM and deploy the EpicBook application.

## Architecture

- Cloud: Microsoft Azure (South Africa North)
- Terraform: resource group, VNet with two subnets, NSG (SSH restricted to controller IP /32, HTTP open), static public IP, Ubuntu 22.04 VM, Azure Database for MySQL Flexible Server (private access, no public endpoint)
- Ansible roles: `common` (baseline packages), `nginx` (reverse proxy on port 80), `epicbook` (Node.js app on port 8080 under PM2, database import)
- Flow: Browser -> Nginx :80 -> Node.js :8080 -> Managed MySQL (private)

## Project structure

    epicbook-prod/
    ├── terraform/azure/        providers.tf, main.tf, variables.tf, outputs.tf
    ├── ansible/
    │   ├── ansible.cfg
    │   ├── inventory.ini
    │   ├── site.yml
    │   ├── group_vars/web.yml
    │   └── roles/{common,nginx,epicbook}
    └── README.md

## How to run

1. Terraform (from `terraform/azure/`, with a `terraform.tfvars` containing `my_ip`, `db_server_name` and `db_password`):

       terraform init && terraform plan && terraform apply

2. Update `ansible/inventory.ini` and `group_vars/web.yml` with the Terraform outputs (`public_ip`, `db_host`).
3. Create the vault file `ansible/group_vars/all/vault.yml` containing `vault_db_password`, then encrypt it with `ansible-vault encrypt`.
4. Run the playbook (from `ansible/`):

       ansible-playbook -i inventory.ini site.yml --ask-vault-pass

## Security notes

- The database password is stored in an Ansible Vault file and a git-ignored `terraform.tfvars`, never in plain text in the repo.
- Terraform state, SSH keys, tfvars and the vault file are excluded through `.gitignore`.
- MySQL has no public endpoint and is reachable only from inside the VNet.
- `require_secure_transport` is OFF for this lab only; enable TLS in production.

## Verification

- `systemctl is-active nginx` returns `active`
- `pm2 status` shows `epicbook` online
- `curl -I http://<public_ip>` returns 200; `/api/cart` returns JSON; `/cart` returns 200
