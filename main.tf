terraform {
    cloud {
    oadsshanization = "MervTrainingOrg"
    hostname = "app.terraform.io" # Optional; defaults to app.terraform.io
    workspaces {
      names = "AzureVault_AzureAD-SSH"
    }
  }

    required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.43.0"
    }
    tls = {
      source = "hashicorp/tls"
      version = "~>4.0"
    }
  }  
}

provider "azurerm" {
  features {}
}

# Create virtual network
resource "azurerm_virtual_network" "adssh" {
  name                = "adssh-Vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.adssh.location
  resource_group_name = azurerm_resource_group.adssh.name
}

# Create subnet
resource "azurerm_subnet" "adssh" {
  name                 = "adssh-Subnet"
  resource_group_name  = azurerm_resource_group.adssh.name
  virtual_network_name = azurerm_virtual_network.adssh.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create public IPs
resource "azurerm_public_ip" "adssh" {
  name                = "adssh-publicip"
  location            = azurerm_resource_group.adssh.location
  resource_group_name = azurerm_resource_group.adssh.name
  allocation_method   = "Static"
  sku                 = "Basic"
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "adssh" {
  name                = "adssh-NetworkSecurityGroup"
  location            = azurerm_resource_group.adssh.location
  resource_group_name = azurerm_resource_group.adssh.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Create network interface
resource "azurerm_network_interface" "adssh" {
  name                = "adssh-nic"
  location            = azurerm_resource_group.adssh.location
  resource_group_name = azurerm_resource_group.adssh.name

  ip_configuration {
    name                          = "adssh-nic_configuration"
    subnet_id                     = azurerm_subnet.adssh.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.adssh_ip.id
  }
}


#Linux VM
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

# Create (and display) an SSH key
resource "tls_private_key" "adssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
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
    public_key = tls_private_key.adssh.public_key_openssh
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
