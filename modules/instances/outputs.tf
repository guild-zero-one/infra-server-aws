output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.simlady_ec2_publica.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.simlady_ec2_publica.public_ip
}

output "private_key_path" {
  description = "Path to the private key file"
  value       = local_file.private_key.filename
}
