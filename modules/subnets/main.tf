resource "aws_subnet" "simlady-private-subnet" {
  vpc_id     = var.vpc_id
  cidr_block = "10.0.0.0/25"
    tags = {
        Name = "simlady-private-subnet"
    }
}

resource "aws_subnet" "simlady-public-subnet" {
  vpc_id     = var.vpc_id
  cidr_block = "10.0.0.128/25"
    tags = {
        Name = "simlady-public-subnet"
    }
}