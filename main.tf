terraform {
    cloud {
    organization = "MervTrainingOrg"
    hostname = "app.terraform.io" # Optional; defaults to app.terraform.io
    workspaces {
      names = "AzureVault_AzureAD-SSH"
    }
  }

    required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.3.0"
    }
  }  
}

resource "azurerm_resource_group" "adssh" {
  name     = "adssh-resources"
  location = var.location
}

resource "azurerm_virtual_network" "adssh" {
  name                = "adssh-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.adssh.location
  resource_group_name = azurerm_resource_group.adssh.name
}

resource "azurerm_subnet" "adssh" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.adssh.name
  virtual_network_name = azurerm_virtual_network.adssh.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "adssh" {
  name                = "adssh-nic"
  location            = azurerm_resource_group.adssh.location
  resource_group_name = azurerm_resource_group.adssh.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.adssh.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "adssh" {
  name                = "adssh-machine"
  resource_group_name = azurerm_resource_group.adssh.name
  location            = azurerm_resource_group.adssh.location
  size                = "Standard_B1s"
  admin_username      = var.admin_username
  network_interface_ids = [
    azurerm_network_interface.adssh.id,
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}