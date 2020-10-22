web_server_location       = "Westus2"
web_server_rg             = "web-rg"
Web_server_address_space  = "web-server"
Address_prefix            =  "10.0.0.0/22"
web_server_address_prefix = "10.0.1.0/24"
web_server_name           = "demogsk"
environments              = "development"
admin_username            = "azuser"
admin_password            = "Azuser123456#"
offer                     = "UbuntuServer"
Publisher                 = "Canonical"
web_server_count          = 2
web_server_subnet         = {
    web-server            = "10.0.1.0/24"
    AzureBastionSubnet    = "10.0.2.0/24"
}