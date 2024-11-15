output "app_service_default_hostname" {
  value = local.web_app.default_hostname
}

output "app_service_name" {
  value = var.app_service_name
}

output "app_service_plan_name" {
  value = var.app_service_plan_name
}

output "resource_group_name" {
  value = var.resource_group_name
}