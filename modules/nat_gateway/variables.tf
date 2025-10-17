variable "vpc_id" {
  description = "VPC ID where the NAT Gateway will be created"
  type        = string
}

variable "public_subnet_id" {
  description = "Public subnet ID where NAT Gateway will be placed"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs to route through NAT Gateway"
  type        = list(string)
}

variable "internet_gateway_id" {
  description = "Internet Gateway ID"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}
