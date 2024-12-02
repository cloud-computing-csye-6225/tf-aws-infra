resource "aws_db_parameter_group" "mydb_parameter_group" {
  name        = "rds-db-param-${var.unique_suffix}"
  family      = var.db_family
  description = "Custom parameter group for RDS"

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
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-${var.unique_suffix}"
  subnet_ids = aws_subnet.private[*].id

  tags = { Name = "rds-subnet-group-${var.unique_suffix}" }
}

resource "aws_db_instance" "rds_instance" {
  instance_class         = var.db_instance_class
  engine                 = var.db_engine
  engine_version         = var.db_engine_version
  allocated_storage      = 10
  port                   = var.db_port
  identifier             = "rds-instance-${var.unique_suffix}"
  db_name                = var.db_name
  username               = jsondecode(aws_secretsmanager_secret_version.db_password_version.secret_string)["username"]
  password               = jsondecode(aws_secretsmanager_secret_version.db_password_version.secret_string)["password"]
  vpc_security_group_ids = [aws_security_group.database_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  parameter_group_name   = aws_db_parameter_group.mydb_parameter_group.name
  multi_az               = false
  publicly_accessible    = false
  skip_final_snapshot    = true
  kms_key_id             = aws_kms_key.rds_key.arn
  storage_encrypted      = true

  tags = { Name = "rds-instance-${var.unique_suffix}" }
}
