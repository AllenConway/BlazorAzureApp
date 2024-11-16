output "app_service_default_hostname" {
  value = azurerm_linux_web_app.app.default_hostname
}

output "app_service_name" {
  value = azurerm_linux_web_app.app.name
}

output "app_service_plan_name" {
  value = azurerm_service_plan.asp.name
}

output "resource_group_name" {
  value = local.resource_group_name
}