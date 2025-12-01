variable "name" {
  type        = string
  description = "Nome base do banco"
  default = "simlady-db"
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "allowed_cidrs" {
  type        = list(string)
  description = "CIDRs com permissão de acesso ao Postgres"
  default     = []
}

variable "db_name" {
  type        = string
  default     = "simladydb"
}

variable "username" {
  type = string
}

variable "password" {
  type      = string
  sensitive = true
}

variable "engine_version" {
  type    = string
  default = "15.3"
}

variable "instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "storage_gb" {
  type    = number
  default = 20
}

variable "max_storage_gb" {
  type    = number
  default = 100
}

variable "port" {
  type    = number
  default = 5432
}

variable "multi_az" {
  type    = bool
  default = false
}

variable "skip_final_snapshot" {
  type    = bool
  default = true
}

variable "security_group_ids" {
  type = string
}