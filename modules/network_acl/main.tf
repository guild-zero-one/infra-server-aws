resource "aws_network_acl" "main" {
  vpc_id = var.vpc_id

  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "${var.environment}-network-acl"
  }
}

resource "aws_network_acl_association" "main" {
  count = length(var.subnet_ids)

  network_acl_id = aws_network_acl.main.id
  subnet_id      = var.subnet_ids[count.index]
}
