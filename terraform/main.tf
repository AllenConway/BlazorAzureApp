terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

# Check if resource group exists
data "azurerm_resource_group" "existing" {
  count = can(data.azurerm_subscription.current.id) ? 1 : 0  # More reliable existence check
  name  = var.resource_group_name
}

data "azurerm_subscription" "current" {}

# Update resource group creation condition
resource "azurerm_resource_group" "rg" {
  count    = can(data.azurerm_resource_group.existing[0].id) ? 0 : 1  # Create only if doesn't exist
  name     = var.resource_group_name
  location = var.location
}

# Simplified reference to resource group
locals {
  resource_group = try(data.azurerm_resource_group.existing[0], azurerm_resource_group.rg[0])
}

# App service plan using local reference
resource "azurerm_service_plan" "asp" {
  name                = var.app_service_plan_name
  location            = local.resource_group.location
  resource_group_name = local.resource_group.name
  os_type            = "Linux"
  sku_name           = "F1"
}

# App service using local reference
resource "azurerm_linux_web_app" "app" {
  name                = var.app_service_name
  location            = local.resource_group.location
  resource_group_name = local.resource_group.name
  service_plan_id     = azurerm_service_plan.asp.id

  site_config {
    application_stack {
      dotnet_version = "8.0"
    }
  }

  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE" = "1"
  }
}