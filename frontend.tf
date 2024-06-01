resource "azurerm_container_app" "twenty_front" {
  name                         = local.front_app_name
  container_app_environment_id = azurerm_container_app_environment.main.id
  resource_group_name          = azurerm_resource_group.main.name
  revision_mode                = "Single"

  depends_on = [azurerm_container_app.twenty_server]

  ingress {
    allow_insecure_connections = false
    external_enabled           = true
    target_port                = 3000
    transport                  = "http"
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  template {
    min_replicas = 1
    max_replicas = 1
    container {
      name   = "twenty-front"
      image  = "docker.io/twentycrm/twenty-front:${local.front_tag}"
      cpu    = local.cpu
      memory = local.memory

      env {
        name  = "REACT_APP_SERVER_BASE_URL"
        value = "https://${azurerm_container_app.twenty_server.ingress[0].fqdn}"
      }
    }
  }
}

resource "azapi_update_resource" "cors" {
  type        = "Microsoft.App/containerApps@2023-05-01"
  resource_id = azurerm_container_app.twenty_front.id
  body = jsonencode({
    properties = {
      configuration = {
        ingress = {
          corsPolicy = {
            allowedOrigins = ["*"]
          }
        }
      }
    }
  })
  depends_on = [azurerm_container_app.twenty_front]
}
