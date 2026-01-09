terraform {
  required_version = ">1.11.4, <2.0.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.28.0"
    }

    databricks = {
      source  = "databricks/databricks"
      version = "1.102.0"
    }
  }

  backend "azurerm" {}
}

provider "azurerm" {
  alias = "hmcts-control"
  features {}
  subscription_id = "04d27a32-7a07-48b3-95b8-3c8691e1a263"
}

provider "azurerm" {
  features {}
}

