# resource "aws_security_group" "simlady_sg" {
#   name        = var.security_group_name
#   vpc_id      = var.vpc_id
#   ingress {
#     from_port   = var.from_port_ingress
#     to_port     = var.to_port_ingress
#     protocol    = "tcp"
#     cidr_blocks = var.cidr_blocks
#   }
#   
#   tags = {
#     Name = var.security_group_name
#   }
# }

resource "aws_security_group" "simlady_sg" {
  name   = var.security_group_name
  vpc_id = var.vpc_id

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  egress {
    from_port   = var.from_port_egress
    to_port     = var.to_port_egress
    protocol    = -1
    cidr_blocks = var.cidr_blocks
  }
  tags = {
    Name = var.security_group_name
  }
}


