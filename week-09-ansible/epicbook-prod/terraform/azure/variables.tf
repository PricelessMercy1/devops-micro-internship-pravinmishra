variable "location" {
  type    = string
  default = "southafricanorth"
}

variable "admin_user" {
  type    = string
  default = "azureuser"
}

variable "vm_size" {
  type    = string
  default = "Standard_D1_v2"
}

variable "public_key_path" {
  type    = string
  default = "~/.ssh/id_rsa_azure.pub"
}

variable "my_ip" {
  type        = string
  description = "Controller public IP; SSH is restricted to this address (/32 added in main.tf)"
}

variable "db_server_name" {
  type        = string
  description = "Globally unique MySQL Flexible Server name"
}

variable "db_name" {
  type    = string
  default = "bookstore"
}

variable "db_user" {
  type    = string
  default = "epicadmin"
}

variable "db_password" {
  type      = string
  sensitive = true
}
