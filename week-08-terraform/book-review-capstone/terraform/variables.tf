variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "eu-north-1"
}

variable "availability_zones" {
  description = "Two availability zones used to spread the Web/App/DB subnet pairs."
  type        = list(string)
  default     = ["eu-north-1a", "eu-north-1b"]
}

variable "project_name" {
  description = "Short name used as a prefix for resource names/tags (e.g. br for book-review)."
  type        = string
  default     = "br"
}

variable "environment" {
  description = "Environment name used for tagging (e.g. dev, staging, prod)."
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "web_subnet_cidrs" {
  description = "CIDR blocks for the two public Web Tier subnets."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "app_subnet_cidrs" {
  description = "CIDR blocks for the two private Application Tier subnets."
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "db_subnet_cidrs" {
  description = "CIDR blocks for the two private Database Tier subnets."
  type        = list(string)
  default     = ["10.0.21.0/24", "10.0.22.0/24"]
}

variable "single_nat_gateway" {
  description = "Use a single shared NAT Gateway (cost-optimized) instead of one NAT Gateway per AZ (fully HA egress)."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Additional tags applied to all resources."
  type        = map(string)
  default     = {}
}

variable "my_ip" {
  description = "Administrator's public IP address in CIDR notation (e.g. \"203.0.113.50/32\"), used to restrict SSH access to the Web Tier. Set this in a terraform.tfvars file (gitignored) or via TF_VAR_my_ip — never commit or hardcode it."
  type        = string

  validation {
    condition     = can(cidrhost(var.my_ip, 0))
    error_message = "my_ip must be a valid CIDR block, e.g. \"203.0.113.50/32\"."
  }

  validation {
    condition     = var.my_ip != "0.0.0.0/0"
    error_message = "my_ip must not be 0.0.0.0/0 — SSH access must be restricted to a specific administrator IP."
  }
}

variable "master_password" {
  description = "Master password for the MySQL database instance. Sensitive — supply via terraform.tfvars (gitignored) or TF_VAR_master_password environment variable, never hardcode or commit."
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.master_password) >= 8
    error_message = "master_password must be at least 8 characters for MySQL security requirements."
  }
}

# ---------------------------------------------------------------------------
# Phase 5 — Compute
# ---------------------------------------------------------------------------

variable "key_name" {
  description = "Name of a pre-existing EC2 key pair (must already exist in the target AWS account/region) used for SSH access to Web/App Tier instances. Terraform does not create this key pair."
  type        = string
  default     = "book-review-key"
}

variable "web_instance_type" {
  description = "EC2 instance type for Web Tier instances."
  type        = string
  default     = "t3.micro"
}

variable "app_instance_type" {
  description = "EC2 instance type for Application Tier instances."
  type        = string
  default     = "t3.micro"
}

variable "root_volume_type" {
  description = "EBS volume type for the root volume of every Web/App Tier instance."
  type        = string
  default     = "gp3"
}

variable "root_volume_size" {
  description = "Size, in GiB, of the root volume of every Web/App Tier instance."
  type        = number
  default     = 20
}
