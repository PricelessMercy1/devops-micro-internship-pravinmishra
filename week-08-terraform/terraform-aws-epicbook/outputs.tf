output "ec2_public_ip" {
  description = "Public IP of the EpicBook EC2 instance"
  value       = module.ec2.public_ip
}

output "rds_endpoint" {
  description = "RDS endpoint (host:port)"
  value       = module.rds.db_endpoint
}

output "rds_address" {
  description = "RDS hostname only (use as 'host' in config.json)"
  value       = module.rds.db_address
}