terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate-arawebapp-demo"
    storage_account_name = "sawebappterraformstate"
    container_name       = "tfstatefile"
    key                  = "terraform.tfstate"
  }
}

