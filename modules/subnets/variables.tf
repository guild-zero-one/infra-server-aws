variable "vpc_id" {
  description = "The ID of the VPC where the subnet will be created"
  type        = string
}

variable "vpc_cdir_block_public" {
  description = "The CIDR block for the public subnet"
  type        = string
  default     = "10.0.0.0/17"
}

variable "vpc_cdir_block_private" {
  description = "The CIDR block for the private subnet"
  type        = string
  default     = "10.0.128.0/17"
}


variable "vpc_cdir_block_private_b" {
  description = "The CIDR block for the private subnet b"
  type        = string
  default     = "10.0.128.0/17"
}