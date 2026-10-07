output "public_ip" {
  description = "VM public IP"
  value       = azurerm_public_ip.pip.ip_address
}

output "admin_user" {
  description = "VM SSH admin user"
  value       = var.admin_user
}

output "db_host" {
  description = "Managed MySQL FQDN (private)"
  value       = azurerm_mysql_flexible_server.db.fqdn
}

output "db_name" {
  description = "Application database name"
  value       = azurerm_mysql_flexible_database.app.name
}

output "db_user" {
  description = "Database admin username"
  value       = var.db_user
}
