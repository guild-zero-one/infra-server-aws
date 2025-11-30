resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key" {
  content         = tls_private_key.ssh_key.private_key_pem
  filename        = "${path.root}/sshKey.pem"
  file_permission = "0600"
}

resource "aws_key_pair" "ssh_key" {
  key_name   = "sshKey"
  public_key = tls_private_key.ssh_key.public_key_openssh

  lifecycle {
    ignore_changes = [public_key]
  }
}