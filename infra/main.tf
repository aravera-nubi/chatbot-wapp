# LOCALS

locals {
  tags = {
    CreatedBy = var.createdby
    Deadline  = var.deadline
    Owner     = var.owner
    Pod       = var.pod
    Project   = var.project
  }
}


# RESOURCES

# ------------------------------------------------------------------------------------------------------
# Resource Group
# ------------------------------------------------------------------------------------------------------

resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.project}-${var.environment}-${var.location}"
  location = var.location
  tags = local.tags
}

#-------------------------------------------------------------------------------------------------------
# Azure Container Registry
# ------------------------------------------------------------------------------------------------------

resource "azurerm_container_registry" "acr" {
  name                = "acr${var.project}${var.environment}${var.location}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = true
  tags                = local.tags
}

# ------------------------------------------------------------------------------------------------------
# App service plan
# ------------------------------------------------------------------------------------------------------

resource "azurerm_service_plan" "service_plan" {
  name                = "asp-${var.project}-${var.environment}-${var.location}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = var.os_type
  sku_name            = var.sku_name
  tags = local.tags
}

# ------------------------------------------------------------------------------------------------------
# App service web app
# ------------------------------------------------------------------------------------------------------

resource "azurerm_linux_web_app" "web_app" {
  name                = "as-${var.service_name}-${var.environment}-${var.location}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.service_plan.id
  https_only          = true
  tags                = local.tags

  site_config {
    always_on      = var.always_on
  }

  app_settings = {
    "WEBSITES_PORT"                        = var.websites_port
    "WEBSITES_CONTAINER_START_TIME_LIMIT"  = var.websites_container_start_time_limit
    "DOCKER_REGISTRY_SERVER_URL"      = "https://${azurerm_container_registry.acr.login_server}"
    "DOCKER_REGISTRY_SERVER_USERNAME" = azurerm_container_registry.acr.admin_username
    "DOCKER_REGISTRY_SERVER_PASSWORD" = azurerm_container_registry.acr.admin_password
  }
  
} 