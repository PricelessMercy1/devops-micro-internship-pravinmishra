variable "project_name" {
  description = "Prefix used to name/tag RDS resources"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of the two private DB subnet IDs (different AZs)"
  type        = list(string)
}

variable "rds_security_group_id" {
  description = "Security Group ID to attach to the RDS instance"
  type        = string
}

variable "db_name" {
  description = "Name of the EpicBook database to create"
  type        = string
  default     = "bookstore"
}

variable "db_username" {
  description = "Master username for the RDS MySQL instance"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Master password for the RDS MySQL instance"
  type        = string
  sensitive   = true
}

variable "instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Allocated storage in GB"
  type        = number
  default     = 20
}

variable "engine_version" {
  description = "MySQL engine version"
  type        = string
  default     = "8.0"
}