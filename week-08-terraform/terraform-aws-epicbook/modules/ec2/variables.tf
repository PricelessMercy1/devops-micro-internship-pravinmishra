variable "project_name" {
  description = "Prefix used to name/tag the EC2 instance"
  type        = string
}

variable "subnet_id" {
  description = "Public subnet ID to launch the instance into"
  type        = string
}

variable "ec2_security_group_id" {
  description = "Security Group ID to attach to the instance"
  type        = string
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