variable "project_name" {
  description = "Short name used as a prefix for all network resource names/tags."
  type        = string
  default     = "br"
}

variable "environment" {
  description = "Environment name (e.g. dev, staging, prod) used for tagging."
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Two availability zones to spread the six subnets across."
  type        = list(string)

  validation {
    condition     = length(var.availability_zones) == 2
    error_message = "Exactly two availability zones are required (one per tier subnet pair)."
  }
}

variable "web_subnet_cidrs" {
  description = "CIDR blocks for the two public Web Tier subnets (one per AZ)."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]

  validation {
    condition     = length(var.web_subnet_cidrs) == 2
    error_message = "Exactly two Web Tier subnet CIDRs are required."
  }
}

variable "app_subnet_cidrs" {
  description = "CIDR blocks for the two private Application Tier subnets (one per AZ)."
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]

  validation {
    condition     = length(var.app_subnet_cidrs) == 2
    error_message = "Exactly two Application Tier subnet CIDRs are required."
  }
}

variable "db_subnet_cidrs" {
  description = "CIDR blocks for the two private Database Tier subnets (one per AZ)."
  type        = list(string)
  default     = ["10.0.21.0/24", "10.0.22.0/24"]

  validation {
    condition     = length(var.db_subnet_cidrs) == 2
    error_message = "Exactly two Database Tier subnet CIDRs are required."
  }
}

variable "single_nat_gateway" {
  description = "If true, create a single NAT Gateway (in AZ-a) shared by both Application Tier subnets, reducing cost at the expense of AZ-level NAT redundancy. If false, create one NAT Gateway per AZ for full HA egress."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Additional tags applied to every network resource."
  type        = map(string)
  default     = {}
}
