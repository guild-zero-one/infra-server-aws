resource "aws_internet_gateway" "igw" {
  vpc_id = var.vpc_id

  tags = {
    Name = "simlady-main-igw"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = var.public_subnet_id
  route_table_id = var.public_route_table_id
}

