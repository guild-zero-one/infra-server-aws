resource "aws_internet_gateway" "simlady_igw" {
  vpc_id = var.vpc_id

  tags = {
    Name = "simlady-igw"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = var.vpc_id

  tags = {
    Name = "simlady-rt-publica"
  }
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = var.cidr_blocks
  gateway_id             = aws_internet_gateway.simlady_igw.id
}

resource "aws_route_table_association" "public_association" {
  subnet_id      = var.public_subnet_id
  route_table_id = aws_route_table.public_route_table.id
}

