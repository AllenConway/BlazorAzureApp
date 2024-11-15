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

locals {
  resource_group = try(data.azurerm_resource_group.existing[0], azurerm_resource_group.rg[0])
}

# Safe data lookups that won't fail if resources don't exist
data "azurerm_service_plan" "existing" {
  count               = try(local.resource_group.name != "", false) ? 1 : 0
  name                = var.app_service_plan_name
  resource_group_name = local.resource_group.name

  depends_on = [azurerm_resource_group.rg]
}

# First check if service plan exists
locals {
  service_plan_exists = try(data.azurerm_service_plan.existing[0].id != "", false)
}

# Create service plan if it doesn't exist
resource "azurerm_service_plan" "asp" {
  count               = local.service_plan_exists ? 0 : 1
  name                = var.app_service_plan_name
  location            = local.resource_group.location
  resource_group_name = local.resource_group.name
  os_type            = "Linux"
  sku_name           = "F1"
}

# Get the current service plan ID
locals {
  current_service_plan_id = local.service_plan_exists ? data.azurerm_service_plan.existing[0].id : azurerm_service_plan.asp[0].id
}

# Create web app
resource "azurerm_linux_web_app" "app" {
  name                = var.app_service_name
  location            = local.resource_group.location
  resource_group_name = local.resource_group.name
  service_plan_id     = local.current_service_plan_id

  site_config {
    application_stack {
      dotnet_version = "8.0"
    }
  }

  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE" = "1"
  }

  lifecycle {
    ignore_changes = [
      app_settings["WEBSITE_RUN_FROM_PACKAGE"]
    ]
  }
}

# Final resource references for outputs
locals {
  service_plan = local.service_plan_exists ? data.azurerm_service_plan.existing[0] : azurerm_service_plan.asp[0]
  web_app     = azurerm_linux_web_app.app
}