# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "main" {
  name                = "workspace${local.resource_suffix}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  # PerGB2018 SKU with 30 days retention
  sku               = "PerGB2018"
  retention_in_days = 30

  # Enable daily cap to control costs
  daily_quota_gb = 1

  tags = var.tags
}
