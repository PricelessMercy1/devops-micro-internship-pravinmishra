output "vpc_id" {
  value = aws_vpc.this.id
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "private_subnet_a_id" {
  value = aws_subnet.private_a.id
}

output "private_subnet_b_id" {
  value = aws_subnet.private_b.id
}

output "ec2_security_group_id" {
  value = aws_security_group.ec2_sg.id
}

output "rds_security_group_id" {
  value = aws_security_group.rds_sg.id
}