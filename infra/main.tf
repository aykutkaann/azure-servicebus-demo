terraform {
    required_providers {
        azurerm = {
            source = "hashicorp/azurerm"
            version = "~> 3.0"
        }
    }
}

provider "azurerm" {
    features {}
}

##Resource Group

resource "azurerm_resource_group" "rg" {
    name = var.resource_group_name
    location = var.location
}

##ServiceBus Namespace

resource "azurerm_servicebus_namespace" "sb" {
    name = var.servicebus_namespace
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    sku = "Standard"
}

## Service Bus Queue

resource "azurerm_servicebus_queue" "queue" {
    name = var.servicebus_queue
    namespace_id = azurerm_servicebus_namespace.sb.id
}

## ACR

resource "azurerm_container_registry" "acr" {
    name = var.acr.name
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    sku = "Basic"
    admin_enabled = true
}

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "law" {
  name                = "law-eventdriven-demo"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
}

# Container Apps Environment
resource "azurerm_container_app_environment" "aca_env" {
  name                       = var.aca_env_name
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
}