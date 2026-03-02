

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "= 4.1.0"
    }
  }

}

provider "azurerm" {
  features {}
  subscription_id = "a411ebbd-65ed-4085-b165-5c7eb29aab1e"
}

data "azurerm_resource_group" "TestProject1" {
  name = "TestProject1"
}

resource "azurerm_log_analytics_workspace" "TestProject1" {
  name                = "law-test1"
  location            = data.azurerm_resource_group.TestProject1.location
  resource_group_name = data.azurerm_resource_group.TestProject1.name
  sku                 = "PerGB2018"
  retention_in_days   = 30

}

resource "azurerm_container_app_environment" "TestProject1" {
  name                       = "dot-net-container-test-environment"
  location                   = data.azurerm_resource_group.TestProject1.location
  resource_group_name        = data.azurerm_resource_group.TestProject1.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.TestProject1.id
}

resource "azurerm_container_app" "TestProject1" {
  name = "dot-net-example-container"
  #location            = data.azurerm_resource_group.TestProject1.location
  resource_group_name          = data.azurerm_resource_group.TestProject1.name
  container_app_environment_id = azurerm_container_app_environment.TestProject1.id
  revision_mode                = "Single"


  ingress {
    allow_insecure_connections = true
    external_enabled           = true
    target_port                = 8080
    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  template {
    container {
      name   = "dotnetexamplecontainer"
      image  = "mcr.microsoft.com/dotnet/samples:dotnetapp"
      cpu    = 1
      memory = "2.0Gi"
    }
  }
}


