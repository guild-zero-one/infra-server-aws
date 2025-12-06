
resource "aws_route_table" "rt" {
  vpc_id = var.vpc_id

  dynamic "route" {
    for_each = var.internet_gateway_id != null ? [var.internet_gateway_id] : var.nat_gateway_id != null ? [var.nat_gateway_id] : []

    content {
      cidr_block = "0.0.0.0/0"

      # Se veio IGW, usa gateway_id
      gateway_id     = var.internet_gateway_id != null ? var.internet_gateway_id : null
      # Se veio NAT, usa nat_gateway_id
      nat_gateway_id = var.nat_gateway_id != null ? var.nat_gateway_id : null
    }
  }

  tags = {
    Name = var.route_table_name
  }
}


resource "aws_route_table_association" "rt_subnet" {
  subnet_id      = var.subnet_id
  route_table_id = aws_route_table.rt.id
}
