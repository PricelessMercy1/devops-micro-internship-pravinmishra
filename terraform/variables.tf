variable "region" {
  description = "AWS region for deployment"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "portfolio-site"
}

variable "environment" {
  description = "Environment name (e.g., production, staging)"
  type        = string
  default     = "production"
}

variable "domain_name" {
  description = "Custom domain name for the CloudFront distribution (optional)"
  type        = string
  default     = ""
}
