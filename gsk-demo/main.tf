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
  for_each = var.web_server_subnet
 name                = each.key
 resource_group_name = azurerm_resource_group.webserver_rg.name
 virtual_network_name = azurerm_virtual_network.web_server_vnet.name
 address_prefix = each.value 
 }
 resource "azurerm_network_interface" "web_server_nic" {
  name = "${var.web_server_name}-${format("%02d",count.index)}-nic"
  location = var.web_server_location
  resource_group_name = azurerm_resource_group.webserver_rg.name
  count               = var.web_server_count
  ip_configuration {
   name = "${var.web_server_name}-ip"
   subnet_id = azurerm_subnet.web_server_subnet["web-server"].id
   private_ip_address_allocation = "dynamic" 
   public_ip_address_id = azurerm_public_ip.web_server_lb_public_ip[count.index].id
   
  }
 }
 resource "azurerm_public_ip" "web_server_lb_public_ip" {
   name = "${var.Web_server_address_space}-${format("%02d",count.index)}-publicip" 
   resource_group_name = azurerm_resource_group.webserver_rg.name
   location = var.web_server_location
   allocation_method = var.environments=="Production" ? "Static": "Dynamic"
   count = var.web_server_count
 }
 data "azurerm_public_ip" "ip" {
  name                = azurerm_public_ip.web_server_lb_public_ip[count.index].name
  resource_group_name = azurerm_resource_group.webserver_rg.name
  depends_on = [azurerm_virtual_machine.web_server]
  count      = var.web_server_count
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
 
 resource "azurerm_subnet_network_security_group_association" "web_server_sag" {
  network_security_group_id = azurerm_network_security_group.web_server_nsg.id
  subnet_id                 = azurerm_subnet.web_server_subnet["web-server"].id
  
 }
 resource "azurerm_virtual_machine" "web_server" {
  name                  = "${var.web_server_name}-${format("%02d",count.index)}"
  location              = var.web_server_location
  resource_group_name   = azurerm_resource_group.webserver_rg.name
  network_interface_ids = [azurerm_network_interface.web_server_nic[count.index].id]
  vm_size               = "Standard_DS1_v2"
  # availability_set_id = azurerm_availability_set.demogsk_avset.id
  count                 = var.web_server_count

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = var.Publisher
    offer     = var.offer
    sku       = lookup(var.sku,var.web_server_location)
    version   = "latest"
  }
  storage_os_disk {
    name              = "demoosdiskgsk-${format("%02d",count.index)}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "${var.web_server_name}-${format("%02d",count.index)}"
    admin_username = var.admin_username
    admin_password = var.admin_password
  }
    os_profile_linux_config {
    disable_password_authentication = false
  }
  
}
# resource "azurerm_lb" "web_server_lb" {
#   name = "${var.Web_server_address_space}-lb"  
 #  resource_group_name = azurerm_resource_group.webserver_rg.name
  # location = var.web_server_location
   #frontend_ip_configuration {
    #name = "${var.Web_server_address_space}-lb-frontend"
    #public_ip_address_id = azurerm_public_ip.web_server_lb_public_ip.id 
      
    
   #}
  
#}
/* resource "azurerm_lb_backend_address_pool" "web_server_backend_pool" {
   name = "${var.Web_server_address_space}-lb-backend-pool"  
   resource_group_name = azurerm_resource_group.webserver_rg.name
   loadbalancer_id = azurerm_lb.web_server_lb.id

}
resource "azurerm_lb_probe" "web_server_lb_http_probe" {
   name = "${var.Web_server_address_space}-lb-http-probe"  
   resource_group_name = azurerm_resource_group.webserver_rg.name
   loadbalancer_id = azurerm_lb.web_server_lb.id
   protocol = "tcp"
   port = "80"
}
resource "azurerm_lb_rule" "web_server_lb_http_rule" {
   name = "${var.Web_server_address_space}-lb-http-rule"  
   resource_group_name = azurerm_resource_group.webserver_rg.name 
   loadbalancer_id = azurerm_lb.web_server_lb.id
   protocol = "tcp"
   frontend_port  = "80"
   backend_port = "80" 
   frontend_ip_configuration_name = "${var.Web_server_address_space}-lb-frontend"
   probe_id = azurerm_lb_probe.web_server_lb_http_probe.id
   backend_address_pool_id = azurerm_lb_backend_address_pool.web_server_backend_pool.id
}
resource "azurerm_network_interface_backend_address_pool_association" "web_server_pool_association" {
  ip_configuration_name   = "${var.web_server_name}-ip"
  backend_address_pool_id = azurerm_lb_backend_address_pool.web_server_backend_pool.id
  network_interface_id   =  azurerm_network_interface.web_server_nic[count.index].id
  count                  = var.web_server_count
  depends_on             = [azurerm_network_interface.web_server_nic]
}
resource "azurerm_availability_set" "demogsk_avset" {
 name                         = "avset"
 location                     = var.web_server_location
 resource_group_name          = azurerm_resource_group.webserver_rg.name
 platform_fault_domain_count  = 2
 platform_update_domain_count = 2
 managed                      = true
} */
resource "null_resource" "bootstrap" {
  connection {
      host     = data.azurerm_public_ip.ip[count.index].ip_address
      type     = "ssh"
      user     = var.admin_username
      password = var.admin_password
    }
  count = var.web_server_count
  provisioner "file" {
    source = "scripts/apache2_install.sh"
    destination = "/tmp/apache2_install.sh"
  }

    provisioner "remote-exec" {
     inline = [ 
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done; sudo rm /var/lib/apt/lists/* ;" ,
      "sudo chown root:root /tmp/apche2_install.sh",
      "sudo chmod +x /tmp/apache2_install.sh",
      "sudo /tmp/apache2_install.sh", 
      ]
  }
  
}