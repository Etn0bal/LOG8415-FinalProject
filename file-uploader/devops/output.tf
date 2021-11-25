output "storage_sas_token" {
  value = data.azurerm_storage_account_sas.SASToken.sas
  sensitive = true
}

output "storage_account_name" {
  value = azurerm_storage_account.FileUploaderStorageAccount.name
}

output "registry_password" {
  value = azurerm_container_registry.acr.admin_password
  sensitive = true
}