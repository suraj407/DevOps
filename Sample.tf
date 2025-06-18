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
