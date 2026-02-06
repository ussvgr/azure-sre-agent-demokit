# Azure Provider - Uses Azure CLI authentication
provider "azurerm" {
  features {
    resource_group {
      # Allow destroying resource groups even if they contain resources not managed by Terraform
      prevent_deletion_if_contains_resources = false
    }
  }

  # Use Azure CLI for authentication
  # Run 'az login' before terraform apply
  use_cli         = true
  subscription_id = var.subscription_id
}

# AzAPI Provider - For preview/unsupported resources
provider "azapi" {
  # Inherits authentication from azurerm provider
  use_cli         = true
  subscription_id = var.subscription_id
}

provider "github" {
}

provider "random" {
}
