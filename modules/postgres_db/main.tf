resource "aws_db_subnet_group" "this" {
  name       = "${var.name}-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "${var.name}-subnet-group"
  }
}

resource "aws_db_instance" "this" {
  identifier             = var.name
  engine                 = "postgres"
  engine_version         = var.engine_version
  instance_class         = var.instance_class
  allocated_storage      = var.storage_gb
  max_allocated_storage  = var.max_storage_gb
  db_name                = var.db_name
  username               = var.username
  password               = var.password
  port                   = var.port
  publicly_accessible    = false
  multi_az               = var.multi_az
  skip_final_snapshot    = var.skip_final_snapshot

  vpc_security_group_ids = [
    var.security_group_ids
  ]

  db_subnet_group_name = aws_db_subnet_group.this.name

  tags = {
    Name = var.name
  }
}
