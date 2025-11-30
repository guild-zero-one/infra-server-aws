variable "vpc_id" {
    description = "The ID of the VPC"
    type        = string
}

variable "nat_gateway_id" {
    description = "The ID of the NAT Gateway"
    type        = string
    default     = null
}

variable "internet_gateway_id" {
    description = "The ID of the Internet Gateway"
    type        = string
    default     = null
}

variable "route_table_name" {
    description = "The name of the Route Table"
    type        = string
}

variable "subnet_id" {
  description = "The ID of the Subnet to associate with the Route Table"
  type        = string
}