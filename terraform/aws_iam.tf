# IAM Role for EC2
resource "aws_iam_role" "ec2_role" {
  name = "ec2-access-role-${var.unique_suffix}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Policy for EC2 Access to Secrets Manager, S3, and KMS
resource "aws_iam_policy" "ec2_secrets_policy" {
  name        = "EC2SecretsPolicy-${var.unique_suffix}"
  description = "Policy for EC2 to access Secrets Manager, S3, and KMS"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:GetSecretValue",
          "kms:Decrypt"
        ],
        Resource = [
          aws_secretsmanager_secret.db_password.arn,
          aws_secretsmanager_secret.email_credentials.arn,
          aws_kms_key.db_password_key.arn,
          aws_kms_key.email_credentials_key.arn
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ],
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.log_bucket.id}",
          "arn:aws:s3:::${aws_s3_bucket.log_bucket.id}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_secrets_policy_attach" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ec2_secrets_policy.arn
}

# IAM Instance Profile for EC2
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2-instance-profile-${var.unique_suffix}"
  role = aws_iam_role.ec2_role.name
}

# Lambda Role
resource "aws_iam_role" "lambda_role" {
  name = "lambda_execution_role-${var.unique_suffix}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}
data "aws_caller_identity" "current" {}

# IAM Policy for Lambda Access to Secrets Manager and SNS
resource "aws_iam_policy" "lambda_secrets_policy" {
  name        = "LambdaSecretsAccessPolicy-${var.unique_suffix}"
  description = "Policy for Lambda to access Secrets Manager and SNS"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:GetSecretValue",
          "kms:Decrypt"
        ],
        Resource = [
          aws_secretsmanager_secret.db_password.arn,
          aws_secretsmanager_secret.email_credentials.arn,
          aws_kms_key.db_password_key.arn,
          aws_kms_key.email_credentials_key.arn
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "sns:Publish",
          "sns:Subscribe"
        ],
        Resource = [
          "arn:aws:sns:${var.region}:${data.aws_caller_identity.current.account_id}:*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_role_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_secrets_policy.arn
}
