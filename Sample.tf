provider "azurerm" {
 features = {}
}
resource "azurerm_resource_group" "dev" {
 name = "myapp-dev-rg"
 location = "East US"
}
resource "azurerm_storage_account" "dev_storage" {
 name = "devstorageacct123"
 resource_group_name = azurerm_resource_group.dev.name
 location = azurerm_resource_group.dev.location
 account_tier = "Standard"
 account_replication_type = "LRS"
}
resource "azurerm_resource_group" "prod" {
 name = "myapp-prod-rg"
 location = "East US"
}
resource "azurerm_storage_account" "prod_storage" {
 name = "prodstorageacct123"
 resource_group_name = azurerm_resource_group.prod.name
 location = azurerm_resource_group.prod.location
 account_tier = "Standard"
 account_replication_type = "GRS"
}
resource "azurerm_mssql_server" "dev_db" {
  name = dev_db
  resource_group_name = azurerm_resource_group.dev.name
  location = "East US"
  version = "12.0"
  administrator_login = "admin
  administrator_login_password = "AdminPassword111"
  minimum_tls_version = var.sql_tls
}​
resource "azurerm_mssql_server" "prod_db" {
  name = prod_db
  resource_group_name = azurerm_resource_group.prod.name
  location = "East US"
  version = "12.0"
  administrator_login = "admin"
  administrator_login_password = "AdminPassword222"
  minimum_tls_version = var.sql_tls
}​
resource "azurerm_network_security_group" "dev" {
  name                = "dev-sg"
  location            = azurerm_resource_group.dev.location
  resource_group_name = azurerm_resource_group.dev.name
}
resource "azurerm_network_security_group" "prod" {
  name                = "prod-sg"
  location            = azurerm_resource_group.prod.location
  resource_group_name = azurerm_resource_group.prod.name
}
resource "azurerm_virtual_network" "network" {
  name                = "infra-network"
  location            = azurerm_resource_group.prod.location
  resource_group_name = azurerm_resource_group.prod.name
  address_space       = ["10.0.0.0/16"]

  subnet {
    name             = "dev-subnet"
    address_prefixes = ["10.0.1.0/24"]
    security_group   = azurerm_network_security_group.dev.id
  }

  subnet {
    name             = "prod-subnet"
    address_prefixes = ["10.0.2.0/24"]
    security_group   = azurerm_network_security_group.prod.id
  }

  tags = {
    name = "network"
  }
}