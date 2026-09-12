output "vpc_id" {
  description = "ID of the VPC."
  value       = module.network.vpc_id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC."
  value       = module.network.vpc_cidr_block
}

output "public_web_subnet_ids" {
  description = "IDs of the two public Web Tier subnets."
  value       = module.network.public_web_subnet_ids
}

output "private_app_subnet_ids" {
  description = "IDs of the two private Application Tier subnets."
  value       = module.network.private_app_subnet_ids
}

output "private_db_subnet_ids" {
  description = "IDs of the two private Database Tier subnets."
  value       = module.network.private_db_subnet_ids
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway."
  value       = module.network.internet_gateway_id
}

output "nat_gateway_ids" {
  description = "IDs of the NAT Gateway(s) providing Application Tier egress."
  value       = module.network.nat_gateway_ids
}

output "public_route_table_id" {
  description = "ID of the public (Web Tier) route table."
  value       = module.network.public_route_table_id
}

output "private_app_route_table_ids" {
  description = "IDs of the private Application Tier route table(s)."
  value       = module.network.private_app_route_table_ids
}

output "private_db_route_table_id" {
  description = "ID of the private Database Tier route table."
  value       = module.network.private_db_route_table_id
}

# ---------------------------------------------------------------------------
# Phase 2 — Security group IDs
# Exposed so later phases (Load Balancing, Compute, Database) can attach
# the correct security group to each resource.
# ---------------------------------------------------------------------------

output "public_alb_sg_id" {
  description = "ID of the Public ALB security group."
  value       = module.security.public_alb_sg_id
}

output "web_sg_id" {
  description = "ID of the Web Tier security group."
  value       = module.security.web_sg_id
}

output "internal_alb_sg_id" {
  description = "ID of the internal (Application) ALB security group."
  value       = module.security.internal_alb_sg_id
}

output "app_sg_id" {
  description = "ID of the Application Tier security group."
  value       = module.security.app_sg_id
}

output "db_sg_id" {
  description = "ID of the Database Tier security group."
  value       = module.security.db_sg_id
}

# ---------------------------------------------------------------------------
# Phase 3 — Load balancer identifiers
# DNS names for verification/testing and target group ARNs for the
# upcoming Compute phase to register Web/App Tier instances against.
# ---------------------------------------------------------------------------

output "public_alb_dns_name" {
  description = "DNS name of the public ALB — the entry point for end-user traffic."
  value       = module.load_balancer.public_alb_dns_name
}

output "internal_alb_dns_name" {
  description = "DNS name of the internal ALB. Resolves only inside the VPC; used by the Web Tier as the backend API base URL."
  value       = module.load_balancer.internal_alb_dns_name
}

output "public_target_group_arn" {
  description = "ARN of the public ALB's target group, for registering Web Tier instances."
  value       = module.load_balancer.public_target_group_arn
}

output "internal_target_group_arn" {
  description = "ARN of the internal ALB's target group, for registering Application Tier instances."
  value       = module.load_balancer.internal_target_group_arn
}

# ---------------------------------------------------------------------------
# Phase 4 — Database endpoints
# Non-sensitive connection metadata only. The master password is managed by
# AWS Secrets Manager (manage_master_user_password) and is never exposed
# here or anywhere else in this configuration.
# ---------------------------------------------------------------------------

output "primary_db_endpoint" {
  description = "Connection endpoint of the primary MySQL instance (\"hostname:port\"). Used by the Application Tier."
  value       = module.database.primary_endpoint
}

output "primary_db_address" {
  description = "Hostname of the primary MySQL instance."
  value       = module.database.primary_address
}

output "primary_db_port" {
  description = "Port the primary MySQL instance accepts connections on."
  value       = module.database.primary_port
}

output "replica_db_endpoint" {
  description = "Connection endpoint of the read replica (\"hostname:port\"). Use for read-only queries where supported by the application."
  value       = module.database.replica_endpoint
}

output "replica_db_address" {
  description = "Hostname of the read replica."
  value       = module.database.replica_address
}

# ---------------------------------------------------------------------------
# Phase 5 — Compute instance identifiers
# Instance IDs and private IPs only, for troubleshooting and jump-host SSH
# (Web -> App). No secrets, no key material.
# ---------------------------------------------------------------------------

output "web_instance_ids" {
  description = "IDs of the two Web Tier EC2 instances."
  value       = module.compute.web_instance_ids
}

output "app_instance_ids" {
  description = "IDs of the two Application Tier EC2 instances."
  value       = module.compute.app_instance_ids
}

output "web_private_ips" {
  description = "Private IP addresses of the two Web Tier instances."
  value       = module.compute.web_private_ips
}

output "web_public_ips" {
  description = "Public IP addresses of the two Web Tier instances, for admin SSH/troubleshooting."
  value       = module.compute.web_public_ips
}

output "app_private_ips" {
  description = "Private IP addresses of the two Application Tier instances (no public IPs exist for this tier)."
  value       = module.compute.app_private_ips
}

output "web_instance_names" {
  description = "Name tags of the two Web Tier instances."
  value       = module.compute.web_instance_names
}

output "app_instance_names" {
  description = "Name tags of the two Application Tier instances."
  value       = module.compute.app_instance_names
}
