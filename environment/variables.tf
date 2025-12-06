variable "environment" {
  description = "Environment name (e.g., dev, prod, staging)"
  type        = string
  default     = "dev"
}

//vpc variables
variable "vpc_cdir_block" {
  description = "The CIDR block for the VPC"
  type        = string
}

//subnet variables
variable "vpc_cdir_block_public" {
  description = "The CIDR block for the public subnet"
  type        = string
}

variable "vpc_cdir_block_private" {
  description = "The CIDR block for the private subnet"
  type        = string
}

variable "db_username" {
  description = "Username for the Postgres database"
  type        = string
}

variable "db_password" {
  description = "Password for the Postgres database"
  type        = string
}

variable "vpc_cdir_block_private_b" {
  description = "The CIDR block for the second private subnet"
  type        = string
}
