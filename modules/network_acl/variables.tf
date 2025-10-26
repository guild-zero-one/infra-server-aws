variable "vpc_id" {
  description = "VPC ID where the ACL will be created"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs to associate with the ACL"
  type        = list(string)
}

variable "environment" {
  description = "Environment name"
  type        = string
}
