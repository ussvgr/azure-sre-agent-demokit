variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group for monitored resources"
  type        = string
  default     = "rg-sre-agent-demoapp"
}

variable "sre_agent_resource_group_name" {
  description = "Name of the resource group for SRE Agent"
  type        = string
  default     = "rg-sre-agent"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "japaneast"
}

variable "project_name" {
  description = "Project name used for naming resources"
  type        = string
  default     = "sreagent"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "github_owner" {
  description = "GitHub organization or user name"
  type        = string
}

variable "github_repo_name" {
  description = "Name of the GitHub repository to create"
  type        = string
  default     = "azure-sre-agent-demoapp"
}

variable "github_push_source_dir" {
  description = "Path to the local directory to push to the GitHub repository. Leave empty to skip pushing files."
  type        = string
  default     = "./app"
}

variable "github_push_commit_message" {
  description = "Commit message for the pushed files"
  type        = string
  default     = "Initial commit from Terraform"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "dev"
    Project     = "sre-agent-demo"
    ManagedBy   = "terraform"
  }
}

# SRE Agent specific variables
variable "sre_agent_name" {
  description = "Name of the SRE Agent"
  type        = string
  default     = "sre-agent"
}

variable "sre_agent_access_level" {
  description = "The access level for the SRE Agent (High or Low)"
  type        = string
  default     = "High"

  validation {
    condition     = contains(["High", "Low"], var.sre_agent_access_level)
    error_message = "Access level must be either 'High' or 'Low'."
  }
}

variable "sre_agent_action_mode" {
  description = "The action mode for the SRE Agent (Review or Auto)"
  type        = string
  default     = "Review"

  validation {
    condition     = contains(["Review", "Auto"], var.sre_agent_action_mode)
    error_message = "Action mode must be either 'Review' or 'Auto'."
  }
}
