provider "aws" {
  profile = var.aws_profile
  region  = var.region
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.tags, { Name = "${var.vpc_name}-${var.unique_suffix}" })
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, { Name = "igw-${var.unique_suffix}" })
}

resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-${var.unique_suffix}"
  }
}

resource "aws_subnet" "private" {
  count                   = length(var.private_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet_cidrs[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "public-subnet-${var.unique_suffix}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(var.tags, { Name = "public-rt-${var.unique_suffix}" })
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, { Name = "private-rt-${var.unique_suffix}" })
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_security_group" "application_sg" {
  name        = "application_sg"
  description = "Security group for EC2 instances hosting web applications"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = var.application_port
    to_port     = var.application_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "application-security-group-${var.unique_suffix}" })
}

resource "aws_security_group" "database_sg" {
  name        = "database_sg"
  description = "Database security group for RDS instance"
  vpc_id      = aws_vpc.main.id


  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.application_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "database-security-group-${var.unique_suffix}" })
}


resource "aws_instance" "app_instance" {
  count                       = length(var.public_subnet_cidrs)
  ami                         = var.custom_ami
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public[count.index].id
  vpc_security_group_ids      = [aws_security_group.application_sg.id]
  associate_public_ip_address = true

  root_block_device {
    volume_size           = 25
    volume_type           = "gp2"
    delete_on_termination = true
  }

  user_data = <<-EOF
    #!/bin/bash
    echo "# App Environment Variables" | sudo tee -a /etc/environment
    echo "SPRING_DATASOURCE_URL=jdbc:mysql://${aws_db_instance.rds_instance.address}:${var.db_port}/${var.db_name}" | sudo tee -a /etc/environment
    echo "SPRING_DATASOURCE_USERNAME=${var.db_username}" | sudo tee -a /etc/environment
    echo "SPRING_DATASOURCE_PASSWORD=${var.db_password}" | sudo tee -a /etc/environment
    source /etc/environment
  EOF

  tags = merge(var.tags, { Name = "web-app-instance-${var.unique_suffix}" })
}

resource "aws_db_parameter_group" "mydb_parameter_group" {
  name        = "rds-webapp-db-parameter-group"
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

# RDS Subnet Group for Private Subnet
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
  identifier             = var.db_identifier
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