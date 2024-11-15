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

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_service_plan" "asp" {
  name                = var.app_service_plan_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = "F1"
}

resource "azurerm_linux_web_app" "app" {
  name                = var.app_service_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.asp.id

  site_config {
    always_on = false
    application_stack {
      dotnet_version = "8.0"
    }

    # These settings help with Blazor apps
    websockets_enabled = true  # Needed for Blazor Server
    http2_enabled = true      # Better performance for Blazor WebAssembly
    minimum_tls_version = "1.2"
    cors {
      allowed_origins = ["*"]
      support_credentials = false
    }
  }

  identity {
    type = "SystemAssigned"
  }

  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE"    = "1"
    "DOTNET_ENVIRONMENT"          = "Production"
    "ASPNETCORE_ENVIRONMENT"      = "Production"
    # Add these for better Blazor performance
    "ASPNETCORE_FORWARDEDHEADERS_ENABLED" = "true"
    "SCM_DO_BUILD_DURING_DEPLOYMENT"      = "true"
  }

  lifecycle {
    ignore_changes = [
      app_settings["WEBSITE_RUN_FROM_PACKAGE"],
      tags
    ]
  }

  depends_on = [
    azurerm_resource_group.rg,
    azurerm_service_plan.asp
  ]
}