// Recursos de rede
module "vpc" {
  source         = "../modules/vpc"
  vpc_cdir_block = var.vpc_cdir_block
}

module "subnets" {
  source                 = "../modules/subnets"
  vpc_id                 = module.vpc.id
  vpc_cdir_block_public  = var.vpc_cdir_block_public
  vpc_cdir_block_private = var.vpc_cdir_block_private
}

module "igw" {
  source = "../modules/internet_gateaway"
  vpc_id = module.vpc.id
}

module "network_acl" {
  source = "../modules/network_acl"

  vpc_id      = module.vpc.id
  subnet_ids  = [module.subnets.public_subnet_id, module.subnets.private_subnet_id]
  environment = var.environment
}

module "rt_public" {
  source = "../modules/route_table"

  vpc_id             = module.vpc.id
  internet_gateway_id = module.igw.id
  route_table_name   = "public-rt"
  subnet_id          = module.subnets.public_subnet_id  
}

module "rt_private" {
  source = "../modules/route_table"

  vpc_id           = module.vpc.id
  nat_gateway_id   = module.nat_gateway.id
  route_table_name = "private-rt"
  subnet_id        = module.subnets.private_subnet_id
}

module "nat_gateway" {
  source = "../modules/nat_gateway"

  vpc_id              = module.vpc.id
  public_subnet_id    = module.subnets.public_subnet_id
  private_subnet_ids  = [module.subnets.private_subnet_id]
  internet_gateway_id = module.igw.id
  environment         = var.environment
}

//Recursos de computação
# module "simlady_ec2_publica" {
#   source             = "../modules/instances"
#   subnet_id          = module.subnets.public_subnet_id
#   security_group_ids = [module.public_security_group.id]
# }

# module "simlady_ec2_privada" {
#   source             = "../modules/instances"
#   subnet_id          = module.subnets.private_subnet_id
#   security_group_ids = [module.private_security_group.id]
# }

# module "public_security_group" {
#   source = "../modules/security_group"
#   vpc_id = module.vpc.id
# }

# module "private_security_group" {
#   source = "../modules/security_group"
#   vpc_id = module.vpc.id
# }


