output "app_service_default_hostname" {
  value = azurerm_linux_web_app.app.default_hostname
}

output "resource_group_name" {
  value = var.resource_group_name
}