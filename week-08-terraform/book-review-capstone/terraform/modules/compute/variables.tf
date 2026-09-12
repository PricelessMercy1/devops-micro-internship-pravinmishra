variable "project_name" {
  description = "Short name used as a prefix for all compute resource names/tags."
  type        = string
  default     = "br"
}

variable "environment" {
  description = "Environment name (e.g. dev, staging, prod) used for tagging."
  type        = string
  default     = "dev"
}

variable "availability_zones" {
  description = "The two availability zones the Web/App Tier subnets are spread across (used for tagging only; subnet placement is driven by the subnet ID lists below)."
  type        = list(string)

  validation {
    condition     = length(var.availability_zones) == 2
    error_message = "Exactly two availability zones are required."
  }
}

# ---------------------------------------------------------------------------
# Networking / placement (from the network module)
# ---------------------------------------------------------------------------

variable "public_web_subnet_ids" {
  description = "IDs of the two public Web Tier subnets (one per AZ), from the network module. Web instances are placed here."
  type        = list(string)

  validation {
    condition     = length(var.public_web_subnet_ids) == 2
    error_message = "Exactly two Web Tier subnet IDs are required (one per AZ)."
  }
}

variable "private_app_subnet_ids" {
  description = "IDs of the two private Application Tier subnets (one per AZ), from the network module. App instances are placed here."
  type        = list(string)

  validation {
    condition     = length(var.private_app_subnet_ids) == 2
    error_message = "Exactly two Application Tier subnet IDs are required (one per AZ)."
  }
}

# ---------------------------------------------------------------------------
# Security groups (from the security module)
# ---------------------------------------------------------------------------

variable "web_sg_id" {
  description = "ID of the Web Tier security group (accepts HTTP from the public ALB and SSH from the admin IP only)."
  type        = string
}

variable "app_sg_id" {
  description = "ID of the Application Tier security group (accepts port 3001 from the internal ALB and SSH from the Web Tier only)."
  type        = string
}

# ---------------------------------------------------------------------------
# Load balancer target groups (from the load-balancer module)
# ---------------------------------------------------------------------------

variable "public_target_group_arn" {
  description = "ARN of the public ALB's target group. Web instances are registered here."
  type        = string
}

variable "internal_target_group_arn" {
  description = "ARN of the internal ALB's target group. Application instances are registered here."
  type        = string
}

variable "public_alb_port" {
  description = "Port the public ALB forwards to on Web Tier targets. Must match the load-balancer module's public_alb_port (default 80)."
  type        = number
  default     = 80
}

variable "internal_alb_port" {
  description = "Port the internal ALB forwards to on Application Tier targets. Must match the load-balancer module's internal_alb_port and the backend's listen port (default 3001)."
  type        = number
  default     = 3001
}

# ---------------------------------------------------------------------------
# Instance configuration
# ---------------------------------------------------------------------------

variable "key_name" {
  description = "Name of a pre-existing EC2 key pair used for SSH access. Terraform does not create this key pair — it must already exist in the target AWS account/region."
  type        = string
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
  description = "EBS volume type for the root volume of every instance."
  type        = string
  default     = "gp3"
}

variable "root_volume_size" {
  description = "Size, in GiB, of the root volume of every instance."
  type        = number
  default     = 20
}

variable "repo_url" {
  description = "Git URL of the book-review-app repository, cloned onto every instance as a bootstrap step. Application build/start configuration is deliberately deferred to the Application Deployment phase, after the repo's actual package.json scripts and directory layout have been inspected."
  type        = string
  default     = "https://github.com/pravinmishraaws/book-review-app.git"
}

variable "tags" {
  description = "Additional tags applied to every compute resource."
  type        = map(string)
  default     = {}
}
