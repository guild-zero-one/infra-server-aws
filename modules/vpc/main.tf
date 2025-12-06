resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cdir_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "simlady-main-vpc"
  }
}
