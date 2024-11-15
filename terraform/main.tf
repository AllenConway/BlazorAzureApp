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

# All data source lookups first
data "azurerm_subscription" "current" {}

data "azurerm_resource_group" "existing" {
  count = try(data.azurerm_subscription.current.id != "", false) ? 1 : 0
  name  = var.resource_group_name
}

# First resource creation - Resource Group
resource "azurerm_resource_group" "rg" {
  count    = try(data.azurerm_resource_group.existing[0].id != "", false) ? 0 : 1
  name     = var.resource_group_name
  location = var.location
}

# Resource group local for use by other resources
locals {
  resource_group = try(data.azurerm_resource_group.existing[0], azurerm_resource_group.rg[0])
}

# Service Plan lookups and creation
data "azurerm_service_plan" "existing" {
  count               = try(local.resource_group.name != "", false) ? 1 : 0
  name                = var.app_service_plan_name
  resource_group_name = local.resource_group.name
  depends_on         = [azurerm_resource_group.rg]
}

locals {
  service_plan_exists = try(data.azurerm_service_plan.existing[0].id != "", false)
}

resource "azurerm_service_plan" "asp" {
  count               = local.service_plan_exists ? 0 : 1
  name                = var.app_service_plan_name
  location            = local.resource_group.location
  resource_group_name = local.resource_group.name
  os_type            = "Linux"
  sku_name           = "F1"
  depends_on         = [local.resource_group]
}

locals {
  current_service_plan_id = local.service_plan_exists ? data.azurerm_service_plan.existing[0].id : azurerm_service_plan.asp[0].id
}

# Web App lookups and creation
data "azurerm_linux_web_app" "existing" {
  count               = try(local.resource_group.name != "", false) ? 1 : 0
  name                = var.app_service_name
  resource_group_name = local.resource_group.name
  depends_on         = [local.resource_group]
}

locals {
  web_app_exists = try(data.azurerm_linux_web_app.existing[0].id != "", false)
}

resource "azurerm_linux_web_app" "app" {
  count               = local.web_app_exists ? 0 : 1
  name                = var.app_service_name
  location            = local.resource_group.location
  resource_group_name = local.resource_group.name
  service_plan_id     = local.current_service_plan_id

  site_config {
    always_on = false
    application_stack {
      dotnet_version = "8.0"
    }
    health_check_path = "/health"  # Add a health check endpoint in your Blazor app
    health_check_eviction_time_in_min = 10
  }

  identity {
    type = "SystemAssigned"
  }

  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE"    = "1"
    "DOTNET_ENVIRONMENT"          = "Production"
    "ASPNETCORE_ENVIRONMENT"      = "Production"
  }

  lifecycle {
    ignore_changes = [
      app_settings["WEBSITE_RUN_FROM_PACKAGE"],
      tags
    ]
  }

  depends_on = [
    local.resource_group,
    azurerm_service_plan.asp
  ]
}

# Final output locals at the end
locals {
  service_plan = local.service_plan_exists ? data.azurerm_service_plan.existing[0] : (length(azurerm_service_plan.asp) > 0 ? azurerm_service_plan.asp[0] : null)
  web_app     = local.web_app_exists ? data.azurerm_linux_web_app.existing[0] : (length(azurerm_linux_web_app.app) > 0 ? azurerm_linux_web_app.app[0] : null)
}