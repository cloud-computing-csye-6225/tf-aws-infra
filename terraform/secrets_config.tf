# KMS Key for EC2 (EBS Volumes)
resource "aws_kms_key" "ebs_key" {
  description             = "KMS key for encrypting EBS volumes"
  enable_key_rotation     = true
  deletion_window_in_days = 30

  tags = {
    Name        = "ebs-encryption-key"
    Environment = var.aws_profile
  }
}

# KMS Key for RDS
resource "aws_kms_key" "rds_key" {
  description             = "KMS key for encrypting RDS"
  enable_key_rotation     = true
  deletion_window_in_days = 30

  tags = {
    Name        = "rds-encryption-key"
    Environment = var.aws_profile
  }
}

# KMS Key for S3
resource "aws_kms_key" "s3_key" {
  description             = "KMS key for encrypting S3 buckets"
  enable_key_rotation     = true
  deletion_window_in_days = 30

  tags = {
    Name        = "s3-encryption-key"
    Environment = var.aws_profile
  }
}

# KMS Key for Secrets Manager (Database Password)
resource "aws_kms_key" "db_password_key" {
  description             = "KMS key for encrypting database password"
  enable_key_rotation     = true
  deletion_window_in_days = 30

  tags = {
    Name        = "db-password-encryption-key"
    Environment = var.aws_profile
  }
}

# KMS Key for Secrets Manager (Email Credentials)
resource "aws_kms_key" "email_credentials_key" {
  description             = "KMS key for encrypting email service credentials"
  enable_key_rotation     = true
  deletion_window_in_days = 30

  tags = {
    Name        = "email-credentials-encryption-key"
    Environment = var.aws_profile
  }
}

# Secrets Manager for Database Password
resource "aws_secretsmanager_secret" "db_password" {
  name       = "db-password-${var.aws_profile}"
  kms_key_id = aws_kms_key.db_password_key.id
  tags = {
    Name        = "db-password-secret"
    Environment = var.aws_profile
  }
}

resource "aws_secretsmanager_secret_version" "db_password_version" {
  secret_id = aws_secretsmanager_secret.db_password.id
  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password
  })
}

# Secrets Manager for Email Credentials
resource "aws_secretsmanager_secret" "email_credentials" {
  name       = "email-credentials-${var.aws_profile}"
  kms_key_id = aws_kms_key.email_credentials_key.id
  tags = {
    Name        = "email-credentials-secret"
    Environment = var.aws_profile
  }
}

resource "aws_secretsmanager_secret_version" "email_credentials_version" {
  secret_id = aws_secretsmanager_secret.email_credentials.id
  secret_string = jsonencode({
    api_key = var.email_api_key
    from    = var.email_from
  })
}
