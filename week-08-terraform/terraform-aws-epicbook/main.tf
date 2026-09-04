terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "network" {
  source = "./modules/network"

  project_name        = var.project_name
  availability_zone_a = var.availability_zone_a
  availability_zone_b = var.availability_zone_b
  ssh_allowed_cidr    = var.ssh_allowed_cidr
}

module "ec2" {
  source = "./modules/ec2"

  project_name           = var.project_name
  subnet_id               = module.network.public_subnet_id
  ec2_security_group_id   = module.network.ec2_security_group_id
  key_name                = var.key_name
  instance_type           = var.instance_type
}

module "rds" {
  source = "./modules/rds"

  project_name           = var.project_name
  private_subnet_ids     = [module.network.private_subnet_a_id, module.network.private_subnet_b_id]
  rds_security_group_id  = module.network.rds_security_group_id
  db_name                = var.db_name
  db_username             = var.db_username
  db_password             = var.db_password
  instance_class           = var.db_instance_class
}