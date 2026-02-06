# Resource Group for monitored resources
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# Resource Group for SRE Agent (separate from monitored resources)
resource "azurerm_resource_group" "sre_agent" {
  name     = var.sre_agent_resource_group_name
  location = var.location
  tags     = var.tags
}

# Random suffix for globally unique names
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

locals {
  resource_suffix = random_string.suffix.result
  name_prefix     = "${var.project_name}-${var.environment}"
}
