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
  vpc_cdir_block_private_b = var.vpc_cdir_block_private_b
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

  vpc_id              = module.vpc.id
  internet_gateway_id = module.igw.id
  route_table_name    = "public-rt"
  subnet_id           = module.subnets.public_subnet_id
}

module "rt_private" {
  source = "../modules/route_table"

  vpc_id           = module.vpc.id
  nat_gateway_id   = module.nat_gateway.id
  route_table_name = "private-rt"
  subnet_id        = module.subnets.private_subnet_id
}

module "rt_private_b" {
  source = "../modules/route_table"

  vpc_id           = module.vpc.id
  nat_gateway_id   = module.nat_gateway.id
  route_table_name = "private-rt-b"
  subnet_id        = module.subnets.private_subnet_b_id
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
module "simlady_ec2_publica" {
  source              = "../modules/instances"
  subnet_id           = module.subnets.public_subnet_id
  security_group_ids  = [module.public_security_group.id]
  associate_public_ip = true
  ec2_name            = "simlady_ec2_publica"
}

module "simlady_ec2_privada_1" {
  source              = "../modules/instances"
  subnet_id           = module.subnets.private_subnet_id
  security_group_ids  = [module.private_security_group.id]
  associate_public_ip = false
  ec2_name            = "simlady_ec2_privada_1"

  depends_on = [module.postgres_db]
  user_data_script = <<-EOF
    #!/bin/bash
    echo "Instância inicializada com user data script" > /home/ubuntu/user_data_log.txt
    echo "DB_HOST=${module.postgres_db.endpoint}" >> /etc/environment
    EOF
}

module "simlady_ec2_privada_2" {
  source              = "../modules/instances"
  subnet_id           = module.subnets.private_subnet_id
  security_group_ids  = [module.private_security_group.id]
  associate_public_ip = false
  ec2_name            = "simlady_ec2_privada_2"

  depends_on = [module.postgres_db]
  user_data_script = <<-EOF
    #!/bin/bash
    echo "Instância inicializada com user data script" > /home/ubuntu/user_data_log.txt
    echo "DB_HOST=${module.postgres_db.endpoint}" >> /etc/environment
    EOF
}

module "public_security_group" {
  source              = "../modules/security_group"
  vpc_id              = module.vpc.id
  security_group_name = "simlady_sg_publico"

  ingress_rules = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

module "private_security_group" {
  source              = "../modules/security_group"
  vpc_id              = module.vpc.id
  security_group_name = "simlady_sg_privado"
  ingress_rules = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [var.vpc_cdir_block]
    },
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = [var.vpc_cdir_block]
    },
    {
      from_port   = 3000
      to_port     = 3000
      protocol    = "tcp"
      cidr_blocks = [var.vpc_cdir_block]
    },
    {
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      cidr_blocks = [var.vpc_cdir_block]
    },
    {
      from_port   = 8000
      to_port     = 8000
      protocol    = "tcp"
      cidr_blocks = [var.vpc_cdir_block]
    },
    {
      from_port   = 30000
      to_port     = 30000
      protocol    = "tcp"
      cidr_blocks = [var.vpc_cdir_block]
    }
  ]
}

module "ssh_key" {
  source = "../modules/ssh_key"
}

// Recursos de banco de dados
module "postgres_db" {
  source             = "../modules/postgres_db"
  name               = "simlady-db"
  vpc_id             = module.vpc.id
  subnet_ids         = [module.subnets.private_subnet_id, module.subnets.private_subnet_b_id]
  security_group_ids = module.private_security_group.id
  db_name            = "simladydb"
  username           = var.db_username
  password           = var.db_password
  engine_version    = "15"
  
}

module "db_security_group" {
  source              = "../modules/security_group"
  vpc_id              = module.vpc.id
  security_group_name = "simlady_db_sg"

  ingress_rules = [
    {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      cidr_blocks = [var.vpc_cdir_block_private]
    }
  ]
  
}


