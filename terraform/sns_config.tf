# Create SNS Topic
resource "aws_sns_topic" "email_topic" {
  name = "email-verification-${var.unique_suffix}"
  tags = merge(var.tags, { Name = "email-topic-${var.unique_suffix}" })
}

