# ---------------------------------------------------------------------------
# No secrets are exposed here. Only instance identifiers/private IPs, which
# are needed for SSH jump-host access (Web -> App) and troubleshooting.
# ---------------------------------------------------------------------------

output "web_instance_ids" {
  description = "IDs of the two Web Tier EC2 instances."
  value       = aws_instance.web[*].id
}

output "app_instance_ids" {
  description = "IDs of the two Application Tier EC2 instances."
  value       = aws_instance.app[*].id
}

output "web_private_ips" {
  description = "Private IP addresses of the two Web Tier instances."
  value       = aws_instance.web[*].private_ip
}

output "app_private_ips" {
  description = "Private IP addresses of the two Application Tier instances (no public IPs exist for this tier)."
  value       = aws_instance.app[*].private_ip
}

output "web_public_ips" {
  description = "Public IP addresses of the two Web Tier instances, for direct SSH/verification during troubleshooting."
  value       = aws_instance.web[*].public_ip
}

output "web_instance_names" {
  description = "Name tags of the two Web Tier instances."
  value       = [for i in aws_instance.web : i.tags["Name"]]
}

output "app_instance_names" {
  description = "Name tags of the two Application Tier instances."
  value       = [for i in aws_instance.app : i.tags["Name"]]
}

output "ami_id" {
  description = "ID of the Ubuntu 22.04 LTS AMI used for both tiers (resolved at apply time via the aws_ami data source)."
  value       = data.aws_ami.ubuntu.id
}
