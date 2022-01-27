provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rggreenhealth" {
  name     = "rg-greenhealth"
  location = "West Europe"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "flask-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rggreenhealth.location
  resource_group_name = azurerm_resource_group.rggreenhealth.name
  }

resource "azurerm_subnet" "subnet" {
  name                 = "flask-subnet"
  resource_group_name  = azurerm_resource_group.rggreenhealth.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
  }

resource "azurerm_public_ip" "publicip" {
  name                = "flask-public-ip"
  resource_group_name = azurerm_resource_group.rggreenhealth.name
  location            = azurerm_resource_group.rggreenhealth.location
  allocation_method   = "Static"
  domain_name_label   = "flask2"
  }

resource "azurerm_network_interface" "netint" {
  name                = "flask-nic"
  resource_group_name = azurerm_resource_group.rggreenhealth.name
  location            = azurerm_resource_group.rggreenhealth.location

  ip_configuration {
    name                          = "primary"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.publicip.id
  }
  }

resource "azurerm_network_security_group" "secgroup" {
  name                = "flask-secgroup"
  location            = azurerm_resource_group.rggreenhealth.location
  resource_group_name = azurerm_resource_group.rggreenhealth.name
  security_rule {
    access                     = "Allow"
    direction                  = "Inbound"
    name                       = "8080"
    priority                   = 100
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_port_range     = "8080"
    destination_address_prefix = azurerm_network_interface.netint.private_ip_address
  }
  security_rule {
    access                     = "Allow"
    direction                  = "Inbound"
    name                       = "22"
    priority                   = 110
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_port_range     = "22"
    destination_address_prefix = azurerm_network_interface.netint.private_ip_address
  }
  }

resource "azurerm_network_interface_security_group_association" "main" {
  network_interface_id      = azurerm_network_interface.netint.id
  network_security_group_id = azurerm_network_security_group.secgroup.id
  }
resource "azurerm_linux_virtual_machine" "linuxvm" {
  name                = "flask-vm"
  resource_group_name = azurerm_resource_group.rggreenhealth.name
  location            = azurerm_resource_group.rggreenhealth.location
  size                = "Standard_B2s"
  admin_username      = "Greenhealth"
  admin_password      = "Greenproject1"
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.netint.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  provisioner "file" {
    source      = "gunicorn.service"
    destination = "/tmp/gunicorn.service"
  }

  provisioner "file" {
    source      = "gunicorn.sh"
    destination = "/home/Greenhealth/gunicorn.sh"
  }

  connection {
    type        = "ssh"
    user        = "Greenhealth"
    password    = "Greenproject1"
    host        = azurerm_public_ip.publicip.ip_address
  }

  provisioner "remote-exec" {
    script = "gunicorn.sh"
  }

  }
  
