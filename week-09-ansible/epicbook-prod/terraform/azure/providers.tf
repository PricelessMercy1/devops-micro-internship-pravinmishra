terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.117"
    }
  }
}

# Authentication comes from the ARM_* environment variables (service principal).
provider "azurerm" {
  features {}
  skip_provider_registration = true
}
