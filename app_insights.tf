# Application Insights
resource "azurerm_application_insights" "main" {
  name                = "app-insights-${local.resource_suffix}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  workspace_id        = azurerm_log_analytics_workspace.main.id
  application_type    = "web"

  # Sampling to reduce costs
  sampling_percentage = 100

  # Daily cap to control costs (GB)
  daily_data_cap_in_gb = 1

  tags = var.tags
}

# Action Group for Smart Detection alerts
resource "azurerm_monitor_action_group" "smart_detection" {
  name                = "Application Insights Smart Detection"
  resource_group_name = azurerm_resource_group.main.name
  short_name          = "SmartDetect"
  enabled             = true

  arm_role_receiver {
    name                    = "Monitoring Contributor"
    role_id                 = "749f88d5-cbae-40b8-bcfc-e573ddc772fa"
    use_common_alert_schema = true
  }

  arm_role_receiver {
    name                    = "Monitoring Reader"
    role_id                 = "43d0d8ad-25c7-4714-9337-8ba259a9fe05"
    use_common_alert_schema = true
  }

  tags = var.tags

  depends_on = [azurerm_resource_group.main]
}

# Smart Detector Alert Rule for Failure Anomalies
resource "azurerm_monitor_smart_detector_alert_rule" "failure_anomalies" {
  name                = "Failure Anomalies - app-insights-${local.resource_suffix}"
  resource_group_name = azurerm_resource_group.main.name
  detector_type       = "FailureAnomaliesDetector"
  scope_resource_ids  = [azurerm_application_insights.main.id]
  severity            = "Sev3"
  frequency           = "PT1M"
  description         = "Failure Anomalies notifies you of an unusual rise in the rate of failed HTTP requests or dependency calls."

  action_group {
    ids = [azurerm_monitor_action_group.smart_detection.id]
  }

  tags = var.tags
}

# Metric Alert Rule for Exceptions
resource "azurerm_monitor_metric_alert" "exceptions" {
  name                = "Exception Alert - app-insights-${local.resource_suffix}"
  resource_group_name = azurerm_resource_group.main.name
  scopes              = [azurerm_application_insights.main.id]
  description         = "Alert when exceptions are detected in Application Insights"
  severity            = 3
  frequency           = "PT1M"
  window_size         = "PT5M"

  criteria {
    metric_namespace = "Microsoft.Insights/components"
    metric_name      = "exceptions/count"
    aggregation      = "Count"
    operator         = "GreaterThan"
    threshold        = 0
  }

  # No action group - alert will be visible in Azure Portal only

  tags = var.tags
}
