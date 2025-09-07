
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
