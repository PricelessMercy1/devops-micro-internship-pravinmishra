variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "eu-north-1"
}

variable "project_name" {
  description = "Prefix used to name/tag all resources"
  type        = string
  default     = "epicbook"
}

variable "availability_zone_a" {
  description = "First Availability Zone (public subnet + private DB subnet A)"
  type        = string
  default     = "eu-north-1a"
}

variable "availability_zone_b" {
  description = "Second Availability Zone (private DB subnet B)"
  type        = string
  default     = "eu-north-1b"
}

variable "ssh_allowed_cidr" {
  description = "CIDR block allowed to SSH into the EC2 instance"
  type        = string
  default     = "0.0.0.0/0"
}

variable "key_name" {
  description = "Name of the existing EC2 key pair to use for SSH"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "db_name" {
  description = "Name of the EpicBook database"
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

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}