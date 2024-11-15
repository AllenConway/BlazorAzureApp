output "app_service_default_hostname" {
  value = azurerm_app_service.app.default_site_hostname
}

output "resource_group_name" {
  value = var.resource_group_name
}