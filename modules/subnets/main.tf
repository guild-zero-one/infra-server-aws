resource "aws_subnet" "public_subnet" {
  vpc_id                  = var.vpc_id
  cidr_block              = var.vpc_cdir_block_public
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = var.vpc_id
  cidr_block        = var.vpc_cdir_block_private
  availability_zone = "us-east-1a"

  tags = {
    Name = "private-subnet"
  }
}


resource "aws_route_table" "public_rt" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.internet_gateway_id
  }

  tags = {
    Name = "public-rt"
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = var.vpc_id

  tags = {
    Name = "private-rt"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_rt.id
}

