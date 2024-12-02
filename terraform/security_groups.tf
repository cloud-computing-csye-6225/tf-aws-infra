# Load Balancer Security Group
resource "aws_security_group" "load_balancer_sg" {
  name        = "load_balancer_sg-${var.unique_suffix}"
  description = "Security group for ALB to access web app"
  vpc_id      = aws_vpc.main.id

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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "load-balancer-security-group-${var.unique_suffix}" })
}

# Application Security Group (Updated)
resource "aws_security_group" "application_sg" {
  name        = "application_sg-${var.unique_suffix}"
  description = "Security group for EC2 instances hosting web applications"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = var.application_port
    to_port         = var.application_port
    protocol        = "tcp"
    security_groups = [aws_security_group.load_balancer_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "application-security-group-${var.unique_suffix}" })
}

# Database Security Group
resource "aws_security_group" "database_sg" {
  name        = "database_sg-${var.unique_suffix}"
  description = "Database security group for RDS instance"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = var.db_port
    to_port         = var.db_port
    protocol        = "tcp"
    security_groups = [aws_security_group.application_sg.id] # Allow access only from app SG
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "database-security-group-${var.unique_suffix}" })
}
