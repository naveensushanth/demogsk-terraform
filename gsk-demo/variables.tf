variable "web_server_location"{
    type=string
}
variable "web_server_rg"{
    type=string
}
variable "Address_prefix"{
    type=string
}
variable "Web_server_address_space" {
    type=string
}
variable "web_server_address_prefix" {
    type=string
}
variable "web_server_name"{
    type=string
}
variable "environments"{
    type=string
}
variable "sku" {
    default = {
        eastus = "18.04-LTS"
        Westus2 = "16.04-LTS"
    }
}
variable "admin_username" {
    type = string
    description = "Administrator user name for virtual machine"
}

variable "admin_password" {
    type = string
    description = "Password must meet Azure complexity requirements"
}
variable "offer" {
    type = string
    description = "offer need to install"
}
variable "Publisher" {
    type = string
    description = "publisher name"
}
variable "web_server_count" {
    type = number
    description = "publisher name"
}
variable "web_server_subnet" {
    type = map 
}