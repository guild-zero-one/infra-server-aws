variable "vpc_id" {
  type = string
}

variable "cidr_blocks" {
  type    = string
  default = "0.0.0.0/0"
}

variable "public_subnet_id" {
  type = string
}
