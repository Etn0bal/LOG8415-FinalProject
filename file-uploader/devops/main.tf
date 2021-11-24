resource "azurerm_resource_group" "FileUploaderRG" {
  name     = "file-uploader-rg"
  location = "East US"
}

## App Service ##

resource "azurerm_app_service_plan" "FileUploaderServicePlan" {
  name                = "file-uploader-appserviceplan"
  location            = azurerm_resource_group.FileUploaderRG.location
  resource_group_name = azurerm_resource_group.FileUploaderRG.name
  kind                = "Linux"
  reserved            = true

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "example" {
  name                = "file-uploader-app"
  location            = azurerm_resource_group.FileUploaderRG.location
  resource_group_name = azurerm_resource_group.FileUploaderRG.name
  app_service_plan_id = azurerm_app_service_plan.FileUploaderServicePlan.id

  site_config {
    scm_type  = "VSTSRM"
    always_on = "true"

    linux_fx_version  = "DOCKER|${azurerm_container_registry.acr.name}.azurecr.io/file-uploader:latest" #define the images to usecfor you application
  }
  app_settings = {
    "DOCKER_REGISTRY_SERVER_URL"      = "",
    "DOCKER_REGISTRY_SERVER_USERNAME" = "",
    "DOCKER_REGISTRY_SERVER_PASSWORD" = "",
    "REACT_APP_STORAGESASTOKEN" = data.azurerm_storage_account_sas.SASToken.sas
    "REACT_APP_STORAGERESOURCENAME" = azurerm_storage_account.FileUploaderStorageAccount.name
  }
  connection_string {
    name  = "StorageAccount"
    type  = "Custom"
    value = azurerm_storage_account.FileUploaderStorageAccount.primary_connection_string
  }
}

## Storage ## 

resource "azurerm_storage_account" "FileUploaderStorageAccount" {
  name                     = "fileuploaderst"
  resource_group_name      = azurerm_resource_group.FileUploaderRG.name
  location                 = azurerm_resource_group.FileUploaderRG.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  allow_blob_public_access = true

  blob_properties {
    cors_rule {
      allowed_headers = ["*"]
      allowed_methods = ["GET", "PUT", "POST", "DELETE"]
      allowed_origins = ["*"]
      exposed_headers  = ["*"]
      max_age_in_seconds = 3000
    }
  }
}

resource "azurerm_storage_container" "FileUploaderContainer" {
  name                  = "files"
  storage_account_name  = azurerm_storage_account.FileUploaderStorageAccount.name
  container_access_type = "public"
}

data "azurerm_storage_account_sas" "SASToken" {
  connection_string = azurerm_storage_account.FileUploaderStorageAccount.primary_connection_string
  https_only        = true

  resource_types {
    service   = true
    container = true
    object    = true
  }

  services {
    blob  = true
    queue = false
    table = false
    file  = false
  }

  start  = "2021-03-21T00:00:00Z"
  expiry = "2022-03-21T00:00:00Z"

  permissions {
    read    = true
    write   = true
    delete  = true
    list    = true
    add     = true
    create  = true
    update  = true
    process = true
  }
}

## Container registry ## 

resource "azurerm_container_registry" "acr" {
  name                = "fileuploaderacr"
  resource_group_name = azurerm_resource_group.FileUploaderRG.name
  location            = azurerm_resource_group.FileUploaderRG.location
  sku                 = "Premium"
  admin_enabled       = false
}


