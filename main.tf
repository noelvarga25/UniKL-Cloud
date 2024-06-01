resource "azurerm_resource_group" "main" {
  name     = "unikl-cloud"
  location = "southeastasia"
}

locals {
  app_env_name = "twenty"

  server_name = "twenty-server"
  server_tag  = "latest"

  front_app_name = "twenty-front"
  front_tag      = "latest"

  db_app_name = "twenty-postgres"
  db_tag      = "latest"

  db_user     = "twenty"
  db_password = "twenty"

  storage_mount_db_name     = "twentydbstoragemount"
  storage_mount_server_name = "twentyserverstoragemount"

  cpu    = 1.0
  memory = "2Gi"
}

resource "azurerm_log_analytics_workspace" "main" {
  name                = "${local.app_env_name}-law"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "random_pet" "example" {
  length    = 2
  separator = ""
}

resource "azurerm_storage_account" "main" {
  name                     = "uniklstg${random_pet.example.id}"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  large_file_share_enabled = true
}

resource "azurerm_storage_share" "db" {
  name                 = "twentydatabaseshare"
  storage_account_name = azurerm_storage_account.main.name
  quota                = 5
  enabled_protocol     = "SMB"
}

resource "azurerm_storage_share" "server" {
  name                 = "twentyservershare"
  storage_account_name = azurerm_storage_account.main.name
  quota                = 5
  enabled_protocol     = "SMB"
}

resource "azurerm_container_app_environment" "main" {
  name                       = "${local.app_env_name}-env"
  location                   = azurerm_resource_group.main.location
  resource_group_name        = azurerm_resource_group.main.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
}

resource "azurerm_container_app_environment_storage" "db" {
  name                         = local.storage_mount_db_name
  container_app_environment_id = azurerm_container_app_environment.main.id
  account_name                 = azurerm_storage_account.main.name
  share_name                   = azurerm_storage_share.db.name
  access_key                   = azurerm_storage_account.main.primary_access_key
  access_mode                  = "ReadWrite"
}

resource "azurerm_container_app_environment_storage" "server" {
  name                         = local.storage_mount_server_name
  container_app_environment_id = azurerm_container_app_environment.main.id
  account_name                 = azurerm_storage_account.main.name
  share_name                   = azurerm_storage_share.server.name
  access_key                   = azurerm_storage_account.main.primary_access_key
  access_mode                  = "ReadWrite"
}
