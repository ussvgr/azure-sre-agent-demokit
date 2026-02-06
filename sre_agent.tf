# Azure SRE Agent using AzAPI provider
# Azure SRE Agent is a preview service (Microsoft.App/agents@2025-05-01-preview)
# Based on sreagent.bicep reference implementation
# SRE Agent is deployed to a dedicated resource group, separate from monitored resources

# Log Analytics Workspace for SRE Agent
resource "azurerm_log_analytics_workspace" "sre_agent" {
  name                = "log-sre-agent-${local.resource_suffix}"
  location            = azurerm_resource_group.sre_agent.location
  resource_group_name = azurerm_resource_group.sre_agent.name

  sku               = "PerGB2018"
  retention_in_days = 30
  daily_quota_gb    = 1

  tags = var.tags
}

# Application Insights for SRE Agent
resource "azurerm_application_insights" "sre_agent" {
  name                = "appi-sre-agent-${local.resource_suffix}"
  location            = azurerm_resource_group.sre_agent.location
  resource_group_name = azurerm_resource_group.sre_agent.name
  workspace_id        = azurerm_log_analytics_workspace.sre_agent.id
  application_type    = "web"

  sampling_percentage  = 100
  daily_data_cap_in_gb = 1

  tags = var.tags
}

# User Assigned Managed Identity for the SRE Agent
# Required because knowledgeGraphConfiguration and actionConfiguration require identity at creation time
resource "azurerm_user_assigned_identity" "sre_agent" {
  name                = "${var.sre_agent_name}-${local.resource_suffix}"
  location            = azurerm_resource_group.sre_agent.location
  resource_group_name = azurerm_resource_group.sre_agent.name
  tags                = var.tags
}

# Azure SRE Agent
resource "azapi_resource" "sre_agent" {
  type      = "Microsoft.App/agents@2025-05-01-preview"
  name      = var.sre_agent_name
  location  = "eastus2"
  parent_id = azurerm_resource_group.sre_agent.id

  # Disable schema validation as this is a preview API not yet in azapi provider schema
  schema_validation_enabled = false

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.sre_agent.id]
  }

  body = {
    properties = {
      # Knowledge Graph Configuration
      knowledgeGraphConfiguration = {
        identity         = azurerm_user_assigned_identity.sre_agent.id
        managedResources = [azurerm_resource_group.main.id]
      }

      # Action Configuration
      actionConfiguration = {
        accessLevel = var.sre_agent_access_level
        identity    = azurerm_user_assigned_identity.sre_agent.id
        mode        = var.sre_agent_action_mode
      }

      # Log Configuration with SRE Agent dedicated Application Insights
      logConfiguration = {
        applicationInsightsConfiguration = {
          appId            = azurerm_application_insights.sre_agent.app_id
          connectionString = azurerm_application_insights.sre_agent.connection_string
        }
      }
    }
  }

  tags = var.tags

  depends_on = [
    azurerm_resource_group.sre_agent,
    azurerm_log_analytics_workspace.sre_agent,
    azurerm_application_insights.sre_agent,
    azurerm_user_assigned_identity.sre_agent
  ]
}

# SRE Agent Administrator role assignment for the current user
# This role allows managing the SRE Agent through the portal
data "azurerm_client_config" "current" {}

resource "azapi_resource" "sre_agent_admin_role_assignment" {
  type      = "Microsoft.Authorization/roleAssignments@2022-04-01"
  name      = uuidv5("dns", "${azapi_resource.sre_agent.id}-${data.azurerm_client_config.current.object_id}-sre-agent-admin")
  parent_id = azapi_resource.sre_agent.id

  # Disable schema validation for role assignment on custom resource
  schema_validation_enabled = false

  body = {
    properties = {
      roleDefinitionId = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/providers/Microsoft.Authorization/roleDefinitions/e79298df-d852-4c6d-84f9-5d13249d1e55"
      principalId      = data.azurerm_client_config.current.object_id
      principalType    = "User"
    }
  }

  depends_on = [azapi_resource.sre_agent]
}

# Role assignment for SRE Agent to access the monitored resource group (Contributor)
resource "azurerm_role_assignment" "sre_agent_monitored_rg_contributor" {
  scope                = azurerm_resource_group.main.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.sre_agent.principal_id
}
