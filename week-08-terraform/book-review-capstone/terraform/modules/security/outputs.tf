output "public_alb_sg_id" {
  description = "ID of the Public ALB security group."
  value       = aws_security_group.public_alb.id
}

output "web_sg_id" {
  description = "ID of the Web Tier security group."
  value       = aws_security_group.web.id
}

output "internal_alb_sg_id" {
  description = "ID of the internal (Application) ALB security group."
  value       = aws_security_group.internal_alb.id
}

output "app_sg_id" {
  description = "ID of the Application Tier security group."
  value       = aws_security_group.app.id
}

output "db_sg_id" {
  description = "ID of the Database Tier security group."
  value       = aws_security_group.db.id
}
