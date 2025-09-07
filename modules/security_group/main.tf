resource "aws_security_group" "simlady_sg_publico" {
  name        = "permite-ssh"
  description = "Permite acesso SSH para o VPC"
  vpc_id      = var.vpc_id
  ingress {
    from_port   = var.from_port_ingress
    to_port     = var.to_port_ingress
    protocol    = "tcp"
    cidr_blocks = var.cidr_blocks
  }
  egress {
    from_port   = var.from_port_egress
    to_port     = var.to_port_egress
    protocol    = -1
    cidr_blocks = var.cidr_blocks
  }
  tags = {
    Name = "simlady_sg_publico"
  }
}
