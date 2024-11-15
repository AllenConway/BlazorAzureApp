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

data "azurerm_subscription" "current" {}

# Check if resource group exists
data "azurerm_resource_group" "existing" {
  count = try(data.azurerm_subscription.current.id != "", false) ? 1 : 0
  name  = var.resource_group_name
}

# Resource group creation condition
resource "azurerm_resource_group" "rg" {
  count    = try(data.azurerm_resource_group.existing[0].id != "", false) ? 0 : 1
  name     = var.resource_group_name
  location = var.location
}

# Simplified references using single locals block
locals {
  resource_group = try(data.azurerm_resource_group.existing[0], azurerm_resource_group.rg[0])
  
  # Try to get existing service plan, return null if not found
  existing_service_plan = try(
    data.azurerm_service_plan.existing[0],
    null
  )
  
  # Try to get existing web app, return null if not found
  existing_web_app = try(
    data.azurerm_linux_web_app.existing[0],
    null
  )
}

# Safe data lookups that won't fail if resources don't exist
data "azurerm_service_plan" "existing" {
  count               = try(local.resource_group.name != "", false) ? 1 : 0
  name                = var.app_service_plan_name
  resource_group_name = local.resource_group.name

  depends_on = [azurerm_resource_group.rg]
}

data "azurerm_linux_web_app" "existing" {
  count               = try(local.resource_group.name != "", false) ? 1 : 0
  name                = var.app_service_name
  resource_group_name = local.resource_group.name

  depends_on = [azurerm_resource_group.rg]
}

# Create service plan if it doesn't exist
resource "azurerm_service_plan" "asp" {
  count               = local.existing_service_plan == null ? 1 : 0
  name                = var.app_service_plan_name
  location            = local.resource_group.location
  resource_group_name = local.resource_group.name
  os_type            = "Linux"
  sku_name           = "F1"
}

# Create web app if it doesn't exist
resource "azurerm_linux_web_app" "app" {
  count               = local.existing_web_app == null ? 1 : 0
  name                = var.app_service_name
  location            = local.resource_group.location
  resource_group_name = local.resource_group.name
  service_plan_id     = local.existing_service_plan != null ? local.existing_service_plan.id : azurerm_service_plan.asp[0].id

  site_config {
    application_stack {
      dotnet_version = "8.0"
    }
  }

  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE" = "1"
  }
}

# Final resource references for outputs
locals {
  service_plan = local.existing_service_plan != null ? local.existing_service_plan : azurerm_service_plan.asp[0]
  web_app     = local.existing_web_app != null ? local.existing_web_app : azurerm_linux_web_app.app[0]
}