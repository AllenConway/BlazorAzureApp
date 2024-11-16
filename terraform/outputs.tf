output "app_service_default_hostname" {
  value = local.web_app.default_hostname
}

output "app_service_name" {
  value       = local.web_app.name
  description = "The name of the web app"
}

output "app_service_plan_name" {
  value = local.service_plan_exists ? data.azurerm_service_plan.existing_asp[0].name : azurerm_service_plan.asp[0].name
}

output "resource_group_name" {
  value = local.resource_group.name
}

output "app_service_plan_id" {
  value = local.current_service_plan_id
}