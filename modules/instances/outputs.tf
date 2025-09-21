output "instance_id" {
  value = aws_instance.simlady_ec2_publica.id
}

output "public_ip" {
  value = aws_instance.simlady_ec2_publica.public_ip
}

resource "local_file" "private_key" {
  content         = tls_private_key.ssh_key.private_key_pem
  filename        = "${var.key_name}.pem"
  file_permission = "0400"
}

output "private_key_pem" {
  value     = tls_private_key.ssh_key.private_key_pem
  sensitive = true
}
