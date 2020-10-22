resource "azurerm_resource_group" "webserver_rg" {
  name     = var.web_server_rg
  location = var.web_server_location
}
resource "azurerm_virtual_network" "web_server_vnet" {
  name = "${var.Web_server_address_space}-vnet"
  location = var.web_server_location
  resource_group_name = azurerm_resource_group.webserver_rg.name
  address_space = [var.Address_prefix]  
}
resource "azurerm_subnet" "web_server_subnet" {
 name = "${var.Web_server_address_space}-subnet" 
 resource_group_name = azurerm_resource_group.webserver_rg.name
 virtual_network_name = azurerm_virtual_network.web_server_vnet.name
 address_prefix = var.web_server_address_prefix 
 }
 resource "azurerm_network_interface" "web_server_nic" {
  name = "${var.web_server_name}-nic"
  location = var.web_server_location
  resource_group_name = azurerm_resource_group.webserver_rg.name
  ip_configuration {
   name = "${var.web_server_name}-ip"
   subnet_id = azurerm_subnet.web_server_subnet.id
   private_ip_address_allocation = "dynamic" 
  }
 }
 resource "azurerm_public_ip" "web_server_public_ip" {
   name = "${var.Web_server_address_space}-publicip" 
   resource_group_name = azurerm_resource_group.webserver_rg.name
   location = var.web_server_location
   allocation_method = var.environments=="Production" ? "Static": "Dynamic"
 }
 resource "azurerm_network_security_group" "web_server_nsg" {
   name = "${var.Web_server_address_space}-nsg"  
   resource_group_name = azurerm_resource_group.webserver_rg.name
   location = var.web_server_location
   security_rule {
    name                       = "SSH-inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "http"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  
 }
 
 resource "azurerm_network_interface_security_group_association" "web_server_nsg_association" {
  network_security_group_id = azurerm_network_security_group.web_server_nsg.id
  network_interface_id = azurerm_network_interface.web_server_nic.id
  
 }
 