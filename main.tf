# provider "azurerm" {
#   subscription_id = "REPLACE-WITH-YOUR-SUBSCRIPTION-ID"
#   client_id       = "REPLACE-WITH-YOUR-CLIENT-ID"
#   client_secret   = "REPLACE-WITH-YOUR-CLIENT-SECRET"
#   tenant_id       = "REPLACE-WITH-YOUR-TENANT-ID"
# }

data "azurerm_resource_group" "network" {
  count = var.resource_group_location == null ? 1 : 0

  name = var.resource_group_name
}

locals {
  resource_group_location = var.resource_group_location == null ? data.azurerm_resource_group.network[0].location : var.resource_group_location
}

resource "azurerm_mssql_database" "db" {
  name                             = "${var.db_name}"
  server_id                        = "${azurerm_mssql_server.server.id}"
  collation                        = "${var.collation}"  
  license_type                     = "LicenseIncluded"
  create_mode                      = "Default"
  sku_name                         = "${var.sku_name}"
  max_size_gb                      = var.max_size_gb
  tags                             = "${var.tags}"
  lifecycle {
    prevent_destroy                = true
  }
}

resource "azurerm_mssql_server" "server" {
  name                         = "${var.server_name}-sqlsvr"
  resource_group_name          = "${var.resource_group_name}"
  location                     = "${local.resource_group_location}"
  version                      = "${var.server_version}"
  administrator_login          = "${var.sql_admin_username}"
  administrator_login_password = "${var.sql_password}"
  tags                         = "${var.tags}"
}

resource "azurerm_mssql_firewall_rule" "app" {
  name                = "${azurerm_mssql_server.server.name}-fwrules-vms"
  server_id           = "${azurerm_mssql_server.server.id}"  
  start_ip_address    = "${var.start_ip_address}"
  end_ip_address      = "${var.end_ip_address}"
}

resource "azurerm_mssql_firewall_rule" "devops" {
  name                = "${azurerm_mssql_server.server.name}-fwrules-devops"
  server_id           = "${azurerm_mssql_server.server.id}"  
  start_ip_address    = "191.235.226.0"
  end_ip_address      = "191.235.226.255"
}
