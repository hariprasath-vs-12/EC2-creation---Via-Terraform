output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "IDs of the two public subnets"
  value       = aws_subnet.public[*].id
}

output "security_group_id" {
  description = "Security group ID (reuse it or reference it from an ALB later)"
  value       = aws_security_group.web.id
}

output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.nginx.id
}

output "instance_public_ip" {
  description = "Public IP of the nginx server"
  value       = aws_instance.nginx.public_ip
}

output "website_url" {
  description = "Open this in a browser once the instance has finished booting (1 to 3 minutes)"
  value       = "http://${aws_instance.nginx.public_ip}"
}
