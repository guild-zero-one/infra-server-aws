variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "ec2_name" {
  type    = string
  default = "simlady_ec2"
}

variable "subnet_id" {
  type = string
}

variable "security_group_ids" {
  type = list(string)
}

variable "key_name" {
  type    = string
  default = "sshKey"
}

variable "associate_public_ip" {
  type    = bool
  default = true
}
