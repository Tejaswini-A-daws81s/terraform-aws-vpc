output "vpc_id" {
  value       = aws_vpc.main.id
}

output "ig_id" {
  value = aws_internet_gateway.main.id
}

