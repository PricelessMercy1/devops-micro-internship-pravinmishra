output "db_endpoint" {
  description = "RDS endpoint (host:port)"
  value       = aws_db_instance.this.endpoint
}

output "db_address" {
  description = "RDS hostname only (use this as 'host' in config.json)"
  value       = aws_db_instance.this.address
}