terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# ---------------------------
# Resource Group
# ---------------------------
resource "azurerm_resource_group" "rg" {
  name     = "Terraform-React-Azure-RG"
  location = "South Africa North"
}

# ---------------------------
# Virtual Network
# ---------------------------
resource "azurerm_virtual_network" "vnet" {
  name                = "Terraform-React-VNet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# ---------------------------
# Subnet
# ---------------------------
resource "azurerm_subnet" "subnet" {
  name                 = "Terraform-React-Subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# ---------------------------
# Network Security Group
# ---------------------------
resource "azurerm_network_security_group" "nsg" {
  name                = "Terraform-React-NSG"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# ---------------------------
# Public IP
# ---------------------------
resource "azurerm_public_ip" "public_ip" {
  name                = "Terraform-React-Public-IP"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                 = "Standard"

  lifecycle {
    create_before_destroy = true
  }
}

# ---------------------------
# Network Interface
# ---------------------------
resource "azurerm_network_interface" "nic" {
  name                = "Terraform-React-NIC"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}

# ---------------------------
# Associate NSG with NIC
# ---------------------------
resource "azurerm_network_interface_security_group_association" "nic_nsg" {
  network_interface_id     = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# ---------------------------
# Linux Virtual Machine
# ---------------------------
resource "azurerm_linux_virtual_machine" "vm" {
  name                = "Terraform-React-VM"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B2ts_v2"

  admin_username                  = "azureadmin"
  admin_password                  = "Reactapp2026"
  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.nic.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  custom_data = filebase64("cloud-init.sh")
}

# ---------------------------
# Output
# ---------------------------
output "public_ip_address" {
  value = azurerm_public_ip.public_ip.ip_address
}