# App Service Plan - Using Free tier (F1)
resource "azurerm_service_plan" "main" {
  name                = "asp-${local.name_prefix}-${local.resource_suffix}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  # Basic tier required for continuous deployment (Free tier doesn't support it)
  os_type  = "Linux"
  sku_name = "B1"

  tags = var.tags
}

# App Service (Web App)
resource "azurerm_linux_web_app" "main" {
  name                = "app-${local.name_prefix}-${local.resource_suffix}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  service_plan_id     = azurerm_service_plan.main.id

  https_only = true

  site_config {
    always_on = true

    application_stack {
      dotnet_version = "10.0"
    }
  }

  app_settings = {
    # Application Insights configuration
    "APPLICATIONINSIGHTS_CONNECTION_STRING"      = azurerm_application_insights.main.connection_string
    "ApplicationInsightsAgent_EXTENSION_VERSION" = "~3"
  }

  tags = var.tags
}

# GitHub Source Control for continuous deployment
resource "azurerm_app_service_source_control" "main" {
  app_id                 = azurerm_linux_web_app.main.id
  repo_url               = github_repository.main.http_clone_url
  branch                 = "main"
  use_manual_integration = false

  github_action_configuration {
    code_configuration {
      runtime_stack   = "dotnetcore"
      runtime_version = "10.0"
    }
    generate_workflow_file = true
  }

  # Wait for files to be pushed to GitHub before configuring source control
  depends_on = [
    github_repository.main,
    null_resource.push_files
  ]
}
