# ---------------------------------------------------------------------------
# Only non-sensitive connection metadata is exposed here. The master
# password is never available as a plain value in this module — it is
# managed entirely by AWS Secrets Manager (manage_master_user_password).
# The `master_user_secret` attribute (which contains the Secrets Manager
# ARN, not the password itself) is intentionally NOT output, to avoid
# encouraging patterns that pull it into logs/state display unnecessarily.
# ---------------------------------------------------------------------------

output "primary_endpoint" {
  description = "Connection endpoint of the primary MySQL instance, in \"hostname:port\" format."
  value       = aws_db_instance.primary.endpoint
}

output "primary_address" {
  description = "Hostname of the primary MySQL instance (no port)."
  value       = aws_db_instance.primary.address
}

output "primary_port" {
  description = "Port the primary MySQL instance accepts connections on."
  value       = aws_db_instance.primary.port
}

output "primary_db_name" {
  description = "Name of the default database created on the primary instance."
  value       = aws_db_instance.primary.db_name
}

output "primary_arn" {
  description = "ARN of the primary MySQL instance."
  value       = aws_db_instance.primary.arn
}

output "replica_endpoint" {
  description = "Connection endpoint of the read replica, in \"hostname:port\" format."
  value       = aws_db_instance.replica.endpoint
}

output "replica_address" {
  description = "Hostname of the read replica (no port)."
  value       = aws_db_instance.replica.address
}

output "replica_port" {
  description = "Port the read replica accepts connections on."
  value       = aws_db_instance.replica.port
}

output "replica_arn" {
  description = "ARN of the read replica."
  value       = aws_db_instance.replica.arn
}
