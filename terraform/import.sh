
#!/bin/bash

# Get variables from tfvars file
RG_NAME=$(terraform output -raw resource_group_name 2>/dev/null || echo "blazor-azure-web-app-rg")
APP_NAME=$(terraform output -raw app_service_name 2>/dev/null || echo "BlazorAzureWebApp")
PLAN_NAME=$(terraform output -raw app_service_plan_name 2>/dev/null || echo "ASP-blazorazurewebapprg")
SUBSCRIPTION_ID=$1

# Import resource group if it exists
terraform import azurerm_resource_group.rg "/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RG_NAME}" || true

# Import app service plan if it exists
terraform import azurerm_service_plan.asp "/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RG_NAME}/providers/Microsoft.Web/serverfarms/${PLAN_NAME}" || true

# Import web app if it exists
terraform import azurerm_linux_web_app.app "/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RG_NAME}/providers/Microsoft.Web/sites/${APP_NAME}" || true