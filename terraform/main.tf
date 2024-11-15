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

# Resource group creation condition
resource "azurerm_resource_group" "rg" {
  count    = can(data.azurerm_resource_group.existing[0].id) ? 0 : 1  # Create only if doesn't exist
  name     = var.resource_group_name
  location = var.location
}

# Simplified reference to resource group
locals {
  resource_group = try(data.azurerm_resource_group.existing[0], azurerm_resource_group.rg[0])
}

# Check for existing service plan only if resource group exists
data "azurerm_service_plan" "existing" {
  count               = can(data.azurerm_resource_group.existing[0].id) ? 1 : 0
  name                = var.app_service_plan_name
  resource_group_name = var.resource_group_name
}

# Check for existing web app only if service plan exists
data "azurerm_linux_web_app" "existing" {
  count               = can(data.azurerm_service_plan.existing[0].id) ? 1 : 0
  name                = var.app_service_name
  resource_group_name = var.resource_group_name
}

# Update local references
locals {
  service_plan = try(data.azurerm_service_plan.existing[0], azurerm_service_plan.asp[0])
  web_app     = try(data.azurerm_linux_web_app.existing[0], azurerm_linux_web_app.app[0])
}

# App service plan using local reference
resource "azurerm_service_plan" "asp" {
  count               = can(data.azurerm_service_plan.existing[0].id) ? 0 : 1
  name                = var.app_service_plan_name
  location            = local.resource_group.location
  resource_group_name = local.resource_group.name
  os_type            = "Linux"
  sku_name           = "F1"
}

# App service using local reference
resource "azurerm_linux_web_app" "app" {
  count               = can(data.azurerm_linux_web_app.existing[0].id) ? 0 : 1
  name                = var.app_service_name
  location            = local.resource_group.location
  resource_group_name = local.resource_group.name
  service_plan_id     = local.service_plan.id

  site_config {
    application_stack {
      dotnet_version = "8.0"
    }
  }

  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE" = "1"
  }
}