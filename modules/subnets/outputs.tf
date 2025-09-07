output "public_subnet_id" {
  value       = aws_subnet.simlady-public-subnet.id
  description = "ID da subrede publica"
}

output "private_subnet_id" {
  value       = aws_subnet.simlady-private-subnet.id
  description = "ID da subrede privada"
}
