data "aws_vpc" "selected" {
  id = var.vpc_id
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = var.vpc_id
  cidr_block              = cidrsubnet(data.aws_vpc.selected.cidr_block, 8, 1)
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = var.vpc_id
  cidr_block        = cidrsubnet(data.aws_vpc.selected.cidr_block, 8, 2)
  availability_zone = "us-east-1b"

  tags = {
    Name = "private-subnet"
  }
}
