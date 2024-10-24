output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}

output "public_subnet_ids" {
  description = "List of IDs for the public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "List of IDs for the private subnets"
  value       = aws_subnet.private[*].id
}

output "application_security_group_id" {
  description = "The ID of the security group for the web application"
  value       = aws_security_group.application_sg.id
}

output "app_instance_public_ips" {
  description = "The public IP addresses of the EC2 instances"
  value       = aws_instance.app_instance[*].public_ip
}

output "app_instance_ids" {
  description = "The IDs of the EC2 instances"
  value       = aws_instance.app_instance[*].id
}


output "public_route_table_id" {
  description = "The ID of the public route table"
  value       = aws_route_table.public.id
}


output "private_route_table_id" {
  description = "The ID of the private route table"
  value       = aws_route_table.private.id
}
