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

# Data source for subscription
data "azurerm_subscription" "current" {}

# Check if the Resource Group exists
data "azurerm_resource_group" "existing_rg" {
  count = try(data.azurerm_subscription.current.id != "", false) ? 1 : 0
  name  = var.resource_group_name
}

# Create Resource Group if it doesn't exist
resource "azurerm_resource_group" "rg" {
  count    = try(data.azurerm_resource_group.existing_rg[0].id != "", false) ? 0 : 1
  name     = var.resource_group_name
  location = var.location
}

# Local variable for Resource Group
locals {
  resource_group = try(data.azurerm_resource_group.existing_rg[0], azurerm_resource_group.rg[0])
}

# Check if the App Service Plan exists
data "azurerm_service_plan" "existing_asp" {
  count               = try(local.resource_group.name != "", false) ? 1 : 0
  name                = var.app_service_plan_name
  resource_group_name = local.resource_group.name
  depends_on          = [local.resource_group]
}

# Determine if the App Service Plan exists
locals {
  service_plan_exists = try(data.azurerm_service_plan.existing_asp[0].id != "", false)
}

# Create App Service Plan if it doesn't exist
resource "azurerm_service_plan" "asp" {
  count               = local.service_plan_exists ? 0 : 1
  name                = var.app_service_plan_name
  location            = local.resource_group.location
  resource_group_name = local.resource_group.name
  os_type             = "Linux"
  sku_name            = "F1"
  depends_on          = [local.resource_group]
}

# Local variable for current Service Plan ID
locals {
  current_service_plan_id = local.service_plan_exists ? data.azurerm_service_plan.existing_asp[0].id : azurerm_service_plan.asp[0].id
}

# Check if the Web App exists
data "azurerm_linux_web_app" "existing_app" {
  count               = try(local.resource_group.name != "", false) ? 1 : 0
  name                = var.app_service_name
  resource_group_name = local.resource_group.name
  depends_on          = [local.resource_group]
}

# Determine if the Web App exists
locals {
  web_app_exists = try(data.azurerm_linux_web_app.existing_app[0].id != "", false)
}

# Create Web App if it doesn't exist
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

    # These settings help with Blazor apps
    websockets_enabled = true  # Needed for Blazor Server
    http2_enabled = true      # Better performance for Blazor WebAssembly
    minimum_tls_version = "1.2"
    use_32_bit_worker = true  # Required for Free tier

    # Add health check path
    health_check_path = "/health"
    
    cors {
      allowed_origins = ["*"]
      support_credentials = false
    }
  }

  identity {
    type = "SystemAssigned"
  }

  app_settings = {
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "true"
    "WEBSITE_RUN_FROM_PACKAGE"           = "1"    # Change this back to "1"
    "DOTNET_ENVIRONMENT"                 = "Production"
    "ASPNETCORE_ENVIRONMENT"             = "Production"
    # Add these for better Blazor performance
    "ASPNETCORE_FORWARDEDHEADERS_ENABLED" = "true"
    "SCM_DO_BUILD_DURING_DEPLOYMENT"      = "true"
    "ASPNETCORE_URLS"                    = "http://0.0.0.0:8080"
    "WEBSITES_PORT"             = "8080"      # Add this setting to match ASPNETCORE_URLS
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

# Local variable for current Web App
locals {
  web_app = local.web_app_exists ? data.azurerm_linux_web_app.existing_app[0] : azurerm_linux_web_app.app[0]
}