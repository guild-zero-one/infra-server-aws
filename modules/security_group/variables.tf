variable "vpc_id" {
  type = string
}

variable "from_port_ingress" {
  type    = number
  default = 22
}

variable "to_port_ingress" {
  type    = number
  default = 22
}

variable "from_port_egress" {
  type    = number
  default = 0
}

variable "to_port_egress" {
  type    = number
  default = 0
}

variable "cidr_blocks" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}
