terraform {
    backend "azurerm"{
        resource_group_name="tfstate-rg"
        storage_account_name = "tfstatestgnav"
        container_name = "tfstatecont"
        key            = "demogsk.tfstate"
    }
}