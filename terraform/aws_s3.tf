resource "aws_s3_bucket" "log_bucket" {
  bucket        = "${uuid()}-${var.unique_suffix}" // Ensure unique bucket name
  force_destroy = true

  tags = merge(var.tags, { Name = "s3-log-bucket-${var.unique_suffix}" })

  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "log_bucket_lifecycle" {
  bucket = aws_s3_bucket.log_bucket.id

  rule {
    id     = "transition-to-standard-ia"
    status = "Enabled"

    filter {
      prefix = ""
    }

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
  }
}

data "aws_iam_user" "current_user" {
  user_name = var.aws_profile == "dev" ? "dev-cli-user" : "demo-cli-user"
}

resource "aws_s3_bucket_policy" "log_bucket_policy" {
  bucket = aws_s3_bucket.log_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = { "AWS" : data.aws_iam_user.current_user.arn },
        Action    = "s3:ListBucket",
        Resource  = "arn:aws:s3:::${aws_s3_bucket.log_bucket.bucket}"
      },
      {
        Effect    = "Allow",
        Principal = { "AWS" : data.aws_iam_user.current_user.arn },
        Action = [
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:DeleteObjectVersion"
        ],
        Resource = "arn:aws:s3:::${aws_s3_bucket.log_bucket.bucket}/*"
      }
    ]
  })
}
