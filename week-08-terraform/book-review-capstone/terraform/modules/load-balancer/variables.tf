variable "project_name" {
  description = "Short name used as a prefix for target group names/tags."
  type        = string
  default     = "br"
}

variable "environment" {
  description = "Environment name (e.g. dev, staging, prod) used for tagging."
  type        = string
  default     = "dev"
}

variable "tags" {
  description = "Additional tags applied to every load-balancing resource."
  type        = map(string)
  default     = {}
}

variable "vpc_id" {
  description = "ID of the VPC the target groups belong to (from the network module)."
  type        = string
}

# ---------------------------------------------------------------------------
# Public ALB — internet-facing, Web Tier subnets.
# ---------------------------------------------------------------------------

variable "public_alb_subnet_ids" {
  description = "IDs of the two public Web Tier subnets the public ALB is attached to."
  type        = list(string)

  validation {
    condition     = length(var.public_alb_subnet_ids) == 2
    error_message = "Exactly two Web Tier subnet IDs are required for the public ALB."
  }
}

variable "public_alb_sg_id" {
  description = "ID of the public-alb-sg security group (from the security module)."
  type        = string
}

variable "public_alb_name" {
  description = "Name of the public ALB. Max 32 characters, alphanumeric and hyphens only."
  type        = string
  default     = "book-review-public-alb"
}

variable "public_target_group_name" {
  description = "Name of the public ALB's target group."
  type        = string
  default     = "book-review-public-tg"
}

variable "public_alb_port" {
  description = "Port the public ALB listens on for the Web Tier."
  type        = number
  default     = 80
}

variable "public_health_check_path" {
  description = "HTTP path used by the public ALB's health check against the Web Tier."
  type        = string
  default     = "/"
}

# ---------------------------------------------------------------------------
# Internal ALB — private, App Tier subnets.
# ---------------------------------------------------------------------------

variable "internal_alb_subnet_ids" {
  description = "IDs of the two private Application Tier subnets the internal ALB is attached to."
  type        = list(string)

  validation {
    condition     = length(var.internal_alb_subnet_ids) == 2
    error_message = "Exactly two Application Tier subnet IDs are required for the internal ALB."
  }
}

variable "internal_alb_sg_id" {
  description = "ID of the internal-alb-sg security group (from the security module)."
  type        = string
}

variable "internal_alb_name" {
  description = "Name of the internal ALB. Max 32 characters, alphanumeric and hyphens only."
  type        = string
  default     = "book-review-internal-alb"
}

variable "internal_target_group_name" {
  description = "Name of the internal ALB's target group."
  type        = string
  default     = "book-review-internal-tg"
}

variable "internal_alb_port" {
  description = "Port the internal ALB listens on for the backend API (must match the Express app's port)."
  type        = number
  default     = 3001
}

variable "internal_health_check_path" {
  description = "HTTP path used by the internal ALB's health check against the Application Tier. Default '/' is a placeholder assumption — confirm against the Express app's actual routes (e.g. a dedicated /health endpoint) during Phase 6 and adjust if needed."
  type        = string
  default     = "/"
}

# ---------------------------------------------------------------------------
# Shared target group / health check tuning.
# ---------------------------------------------------------------------------

variable "target_type" {
  description = "Type of target registered with both target groups. 'instance' is used because compute will be EC2-based."
  type        = string
  default     = "instance"
}

variable "health_check_healthy_threshold" {
  description = "Number of consecutive successful health checks required before a target is considered healthy."
  type        = number
  default     = 3
}

variable "health_check_unhealthy_threshold" {
  description = "Number of consecutive failed health checks required before a target is considered unhealthy."
  type        = number
  default     = 3
}

variable "health_check_interval" {
  description = "Approximate time, in seconds, between health checks of an individual target."
  type        = number
  default     = 30
}

variable "health_check_timeout" {
  description = "Amount of time, in seconds, during which no response means a failed health check."
  type        = number
  default     = 6
}

variable "enable_deletion_protection" {
  description = "If true, disables deletion of the ALBs via the AWS API. Keep false for this dev/capstone environment so Terraform can tear it down cleanly."
  type        = bool
  default     = false
}
