terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.63"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# ---------------------------------------------------------------------------
# Phase 1 — Networking
# VPC, six subnets (Web/App/DB x 2 AZs), Internet Gateway, NAT Gateway,
# and route tables enforcing the required traffic boundaries.
# ---------------------------------------------------------------------------

module "network" {
  source = "./modules/network"

  project_name       = var.project_name
  environment        = var.environment
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
  web_subnet_cidrs   = var.web_subnet_cidrs
  app_subnet_cidrs   = var.app_subnet_cidrs
  db_subnet_cidrs    = var.db_subnet_cidrs
  single_nat_gateway = var.single_nat_gateway
  tags               = var.tags
}

# ---------------------------------------------------------------------------
# Phase 2 — Security
# Five security groups forming a strict traffic chain:
#   Internet -> public-alb-sg -> web-sg -> internal-alb-sg -> app-sg -> db-sg
# No 0.0.0.0/0 exposure on ports 3001 or 3306. SSH to the App Tier only via
# the Web Tier (jump-host pattern). See modules/security/main.tf for the
# per-rule rationale.
# ---------------------------------------------------------------------------

module "security" {
  source = "./modules/security"

  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.network.vpc_id
  my_ip        = var.my_ip
  tags         = var.tags
}

# ---------------------------------------------------------------------------
# Phase 3 — Load Balancing
# Public ALB (internet-facing, Web Tier subnets, port 80) and internal ALB
# (private, App Tier subnets, port 3001). Both are plain forward listeners
# with no targets registered yet — instances are attached in the Compute
# phase. See modules/load-balancer/main.tf for the HTTP-vs-TCP design note
# on the internal target group.
# ---------------------------------------------------------------------------

module "load_balancer" {
  source = "./modules/load-balancer"

  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.network.vpc_id
  tags         = var.tags

  public_alb_subnet_ids = module.network.public_web_subnet_ids
  public_alb_sg_id      = module.security.public_alb_sg_id

  internal_alb_subnet_ids = module.network.private_app_subnet_ids
  internal_alb_sg_id      = module.security.internal_alb_sg_id
}

# ---------------------------------------------------------------------------
# Phase 4 — Database
# RDS MySQL with Multi-AZ for HA and a read replica for read scaling.
# Master password is supplied via terraform.tfvars (gitignored) or
# TF_VAR_master_password — never hardcoded or committed to version control.
# ---------------------------------------------------------------------------

module "database" {
  source = "./modules/database"

  project_name          = var.project_name
  environment           = var.environment
  availability_zones    = var.availability_zones
  vpc_id                = module.network.vpc_id
  private_db_subnet_ids = module.network.private_db_subnet_ids
  db_security_group_id  = module.security.db_sg_id
  master_password       = var.master_password
  tags                  = var.tags
}

# ---------------------------------------------------------------------------
# Phase 5 — Compute
# Two Web Tier instances (public subnets, registered with the public ALB
# target group) and two Application Tier instances (private subnets,
# registered with the internal ALB target group). user_data is bootstrap-only
# (runtime + PM2 + nginx-on-web + repo clone) — application build/start
# configuration and DB credential wiring are deferred to the Application
# Deployment phase. See modules/compute/main.tf for the full rationale.
# ---------------------------------------------------------------------------

module "compute" {
  source = "./modules/compute"

  project_name       = var.project_name
  environment        = var.environment
  availability_zones = var.availability_zones

  public_web_subnet_ids  = module.network.public_web_subnet_ids
  private_app_subnet_ids = module.network.private_app_subnet_ids

  web_sg_id = module.security.web_sg_id
  app_sg_id = module.security.app_sg_id

  public_target_group_arn   = module.load_balancer.public_target_group_arn
  internal_target_group_arn = module.load_balancer.internal_target_group_arn

  # NOTE: public_alb_port/internal_alb_port are intentionally left at their
  # module defaults (80/3001) rather than wired from module.load_balancer,
  # because the load-balancer module does not expose those ports as outputs
  # (see modules/load-balancer/outputs.tf). Both modules' defaults are kept
  # in sync manually — if either port is ever overridden, override it in
  # both places or add the corresponding outputs to the load-balancer module.

  key_name          = var.key_name
  web_instance_type = var.web_instance_type
  app_instance_type = var.app_instance_type
  root_volume_type  = var.root_volume_type
  root_volume_size  = var.root_volume_size

  tags = var.tags
}
