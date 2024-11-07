resource "aws_db_parameter_group" "mydb_parameter_group" {
  name        = "rds-webapp-db-parameter-group-${var.unique_suffix}"
  family      = var.db_family
  description = "parameters for the webapp database"

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }

  parameter {
    name  = "collation_server"
    value = "utf8mb4_unicode_ci"
  }

  parameter {
    name  = "max_connections"
    value = "100"
  }

  tags = merge(var.tags, { Name = "mydb-parameter-group-${var.unique_suffix}" })
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group-${var.unique_suffix}"
  subnet_ids = aws_subnet.private[*].id

  tags = merge(var.tags, { Name = "rds-subnet-group-${var.unique_suffix}" })
}

resource "aws_db_instance" "rds_instance" {
  instance_class         = var.db_instance_class
  engine                 = var.db_engine
  engine_version         = var.db_engine_version
  allocated_storage      = 10
  port                   = var.db_port
  identifier             = "${var.db_identifier}-${var.unique_suffix}"
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  vpc_security_group_ids = [aws_security_group.database_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  parameter_group_name   = aws_db_parameter_group.mydb_parameter_group.name
  multi_az               = false
  publicly_accessible    = false
  skip_final_snapshot    = true

  tags = merge(var.tags, { Name = "rds-instance-${var.unique_suffix}" })
}
