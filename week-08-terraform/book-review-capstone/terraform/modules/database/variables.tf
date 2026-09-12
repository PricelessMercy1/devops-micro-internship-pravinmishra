variable "project_name" {
  description = "Short name used as a prefix for all database resource names/tags."
  type        = string
  default     = "br"
}

variable "environment" {
  description = "Environment name (e.g. dev, staging, prod) used for tagging."
  type        = string
  default     = "dev"
}

variable "vpc_id" {
  description = "ID of the VPC the database subnet group is created in."
  type        = string
}

variable "private_db_subnet_ids" {
  description = "IDs of the two private Database Tier subnets (one per AZ), from the network module."
  type        = list(string)

  validation {
    condition     = length(var.private_db_subnet_ids) == 2
    error_message = "Exactly two Database Tier subnet IDs are required (one per AZ)."
  }
}

variable "availability_zones" {
  description = "The two availability zones the Database Tier subnets are spread across. Used to place the read replica in the AZ that differs from wherever the Multi-AZ primary actually lands."
  type        = list(string)

  validation {
    condition     = length(var.availability_zones) == 2
    error_message = "Exactly two availability zones are required."
  }
}

variable "db_security_group_id" {
  description = "ID of the Database Tier security group (accepts MySQL 3306 from the Application Tier only), from the security module."
  type        = string
}

variable "db_instance_class" {
  description = "RDS instance class for the primary (and, by default, the read replica)."
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Allocated storage for the primary instance, in GiB."
  type        = number
  default     = 20
}

variable "storage_type" {
  description = "EBS storage type backing the RDS instances. Fixed to gp3 (general-purpose SSD) for this project — not intended to be overridden."
  type        = string
  default     = "gp3"

  validation {
    condition     = var.storage_type == "gp3"
    error_message = "storage_type is fixed to \"gp3\" for this project."
  }
}

variable "engine_version" {
  description = "MySQL engine version (major.minor, e.g. \"8.0\"). RDS resolves this to the latest compatible patch version."
  type        = string
  default     = "8.0"
}

variable "backup_retention_period" {
  description = "Number of days to retain automated backups. Must be at least 1 — required both for point-in-time recovery and as a precondition for creating a read replica."
  type        = number
  default     = 1

  validation {
    condition     = var.backup_retention_period >= 1
    error_message = "backup_retention_period must be at least 1 day to support the read replica and point-in-time recovery."
  }
}

variable "master_username" {
  description = "Master username for the MySQL instance."
  type        = string
  default     = "bookadmin"
}

variable "master_password" {
  description = "Master password for the MySQL instance. Sensitive — supply via terraform.tfvars (gitignored) or TF_VAR_master_password environment variable, never hardcode."
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.master_password) >= 8
    error_message = "master_password must be at least 8 characters for MySQL security requirements."
  }
}

variable "tags" {
  description = "Additional tags applied to every database resource."
  type        = map(string)
  default     = {}
}
