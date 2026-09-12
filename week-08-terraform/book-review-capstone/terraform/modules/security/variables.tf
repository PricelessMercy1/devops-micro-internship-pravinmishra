variable "project_name" {
  description = "Short name used as a prefix for all security group names/tags."
  type        = string
  default     = "br"
}

variable "environment" {
  description = "Environment name (e.g. dev, staging, prod) used for tagging."
  type        = string
  default     = "dev"
}

variable "vpc_id" {
  description = "ID of the VPC the security groups belong to (from the network module)."
  type        = string
}

variable "my_ip" {
  description = "Administrator's public IP address in CIDR notation (e.g. \"203.0.113.50/32\"), allowed to SSH into the Web Tier. Never defaulted to 0.0.0.0/0."
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

variable "tags" {
  description = "Additional tags applied to every security resource."
  type        = map(string)
  default     = {}
}
