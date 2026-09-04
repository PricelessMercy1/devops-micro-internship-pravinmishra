variable "project_name" {
  description = "Prefix used to name/tag all network resources"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet (EC2)"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_a_cidr" {
  description = "CIDR block for private DB subnet A"
  type        = string
  default     = "10.0.2.0/24"
}

variable "private_subnet_b_cidr" {
  description = "CIDR block for private DB subnet B"
  type        = string
  default     = "10.0.3.0/24"
}

variable "availability_zone_a" {
  description = "Availability Zone for the public subnet and private DB subnet A"
  type        = string
}

variable "availability_zone_b" {
  description = "Availability Zone for private DB subnet B"
  type        = string
}

variable "ssh_allowed_cidr" {
  description = "CIDR block allowed to SSH into the EC2 instance"
  type        = string
  default     = "0.0.0.0/0"
}