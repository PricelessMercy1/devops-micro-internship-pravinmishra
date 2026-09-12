output "public_alb_arn" {
  description = "ARN of the public (internet-facing) ALB."
  value       = aws_lb.public.arn
}

output "public_alb_dns_name" {
  description = "DNS name of the public ALB. This is the entry point for end-user traffic (via a browser or curl) once the Web Tier is registered."
  value       = aws_lb.public.dns_name
}

output "public_target_group_arn" {
  description = "ARN of the public ALB's target group. Consumed by the Compute module to register Web Tier instances."
  value       = aws_lb_target_group.public.arn
}

output "internal_alb_arn" {
  description = "ARN of the internal (private) ALB."
  value       = aws_lb.internal.arn
}

output "internal_alb_dns_name" {
  description = "DNS name of the internal ALB. Resolves only inside the VPC. The Web Tier uses this as the backend API base URL (port 3001) — never expose this value outside the VPC/app configuration."
  value       = aws_lb.internal.dns_name
}

output "internal_target_group_arn" {
  description = "ARN of the internal ALB's target group. Consumed by the Compute module to register Application Tier instances."
  value       = aws_lb_target_group.internal.arn
}
