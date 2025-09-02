
module "vpc" {
    source = "../modules/vpc"
}

module "subnets" {
    source = "../modules/subnets"
    vpc_id = module.vpc.id
}