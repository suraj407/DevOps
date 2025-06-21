provider "azurerm" {
}

resource "azurerm_resource_group" "dev" {
  name     = "myapp-dev-rg"
  location = "East US"
}

resource "azurerm_resource_group" "prod" {
  name     = "myapp-prod-rg"
  location = "East US"
}

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

resource "azurerm_virtual_network" "dev_network" {
  name                = "infra-dev-network"
  location            = azurerm_resource_group.dev.location
  resource_group_name = azurerm_resource_group.dev.name
  address_space       = ["10.0.0.0/8"]

  tags = {
    name = "dev-network"
  }
}

resource "azurerm_virtual_network" "prod_network" {
  name                = "infra-prod-network"
  location            = azurerm_resource_group.prod.location
  resource_group_name = azurerm_resource_group.prod.name
  address_space       = ["192.168.0.0/16"]

  tags = {
    name = "prod-network"
  }
}

resource "azurerm_subnet" "dev_subnet1" {
  name                 = "dev-subnet-1"
  resource_group_name  = azurerm_resource_group.dev.name
  virtual_network_name = azurerm_virtual_network.dev_network.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "dev_subnet2" {
  name                 = "dev-subnet-2"
  resource_group_name  = azurerm_resource_group.dev.name
  virtual_network_name = azurerm_virtual_network.dev_network.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_subnet" "prod_subnet1" {
  name                 = "prod-subnet-1"
  resource_group_name  = azurerm_resource_group.prod.name
  virtual_network_name = azurerm_virtual_network.prod_network.name
  address_prefixes     = ["192.168.2.0/24"]
}

resource "azurerm_subnet" "prod_subnet2" {
  name                 = "prod-subnet-2"
  resource_group_name  = azurerm_resource_group.prod.name
  virtual_network_name = azurerm_virtual_network.prod_network.name
  address_prefixes     = ["10.1.2.0/24"]
}

resource "azurerm_storage_account" "dev_storage" {
  name                     = "devstorageacct123"
  resource_group_name      = azurerm_resource_group.dev.name
  location                 = azurerm_resource_group.dev.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_account" "prod_storage" {
  name                     = "prodstorageacct123"
  resource_group_name      = azurerm_resource_group.prod.name
  location                 = azurerm_resource_group.prod.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_mssql_server" "dev_db" {
  name                         = "dev-db"
  resource_group_name          = azurerm_resource_group.dev.name
  location                     = azurerm_resource_group.dev.location
  version                      = "12.0"
  administrator_login          = "admin"
  administrator_login_password = "AdminPassword111"
  minimum_tls_version          = "1.2"
}

resource "azurerm_mssql_server" "prod_db" {
  name                         = "prod-db"
  resource_group_name          = azurerm_resource_group.prod.name
  location                     = azurerm_resource_group.prod.location
  version                      = "12.0"
  administrator_login          = "admin"
  administrator_login_password = "AdminPassword222"
  minimum_tls_version          = "1.2"
}

resource "azurerm_private_endpoint" "dev_sql_private_endpoint" {
  name                = "dev-db-private-endpoint"
  location            = azurerm_resource_group.dev.location
  resource_group_name = azurerm_resource_group.dev.name
  subnet_id           = azurerm_subnet.dev_subnet1.id

  private_service_connection {
    name                           = "dev-db-privateserviceconnection"
    private_connection_resource_id = azurerm_mssql_server.dev_db.id
    is_manual_connection           = false
    subresource_names              = ["sqlServer"]
  }
}

resource "azurerm_private_endpoint" "prod_sql_private_endpoint" {
  name                = "prod-db-private-endpoint"
  location            = azurerm_resource_group.prod.location
  resource_group_name = azurerm_resource_group.prod.name
  subnet_id           = azurerm_subnet.prod_subnet1.id

  private_service_connection {
    name                           = "prod-db-privateserviceconnection"
    private_connection_resource_id = azurerm_mssql_server.prod_db.id
    is_manual_connection           = false
    subresource_names              = ["sqlServer"]
  }
}

resource "azurerm_network_interface" "dev_nic1" {
  name                = "vm-dev-nic"
  location            = azurerm_resource_group.dev.location
  resource_group_name = azurerm_resource_group.dev.name

  ip_configuration {
    name                          = "vmnic-ip-private"
    subnet_id                     = azurerm_subnet.dev_subnet1.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "prod_nic1" {
  name                = "vm-prod-nic"
  location            = azurerm_resource_group.prod.location
  resource_group_name = azurerm_resource_group.prod.name

  ip_configuration {
    name                          = "vmnic-ip-private"
    subnet_id                     = azurerm_subnet.prod_subnet1.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "dev_vm" {
  name                = "devvmachine"
  location            = azurerm_resource_group.dev.location
  resource_group_name = azurerm_resource_group.dev.name
  size                = "Standard_D2d_v5"
  admin_username        = "azureadmin"
  admin_password        = "Password12234567890"
  network_interface_ids = [azurerm_network_interface.dev_nic1.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}

resource "azurerm_windows_virtual_machine" "prod_vm" {
  name                = "prodvmachine"
  location            = azurerm_resource_group.prod.location
  resource_group_name = azurerm_resource_group.prod.name
  size                = "Standard_D2d_v5"
  admin_username        = "azureadmin"
  admin_password        = "Password12234567890"
  network_interface_ids = [azurerm_network_interface.prod_nic1.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}
