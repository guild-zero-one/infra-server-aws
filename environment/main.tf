module "vpc" {
  source = "../modules/vpc"
}

module "subnets" {
  source = "../modules/subnets"
  vpc_id = module.vpc.id
}

module "security_group" {
  source = "../modules/security_group"
  vpc_id = module.vpc.id
}

module "simlady_ec2_publica" {
  source             = "../modules/instances"
  subnet_id          = module.subnets.public_subnet_id
  security_group_ids = [module.security_group.id_publico]
}

module "igw" {
  source           = "../modules/internet_gateaway"
  vpc_id           = module.vpc.id
  public_subnet_id = module.subnets.public_subnet_id
}

module "network_acl" {
  source = "../modules/network_acl"

  vpc_id      = module.vpc.id
  subnet_ids  = [module.subnets.public_subnet_id, module.subnets.private_subnet_id]
  environment = var.environment
}

module "nat_gateway" {
  source = "../modules/nat_gateway"

  vpc_id              = module.vpc.id
  public_subnet_id    = module.subnets.public_subnet_id
  private_subnet_ids  = [module.subnets.private_subnet_id]
  internet_gateway_id = module.igw.id
  environment         = var.environment
}
