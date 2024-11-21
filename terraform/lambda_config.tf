# Create Lambda Function
resource "aws_lambda_function" "email_lambda" {
  function_name = "email-lambda-${var.unique_suffix}"
  role          = aws_iam_role.lambda_role.arn
  handler       = "com.serverless.emailHandler.EmailNotificationHandler::handleRequest"
  runtime       = "java11"
  filename      = var.lambda_file_path

  environment {
    variables = {
      DB_URL        = "jdbc:mysql://${aws_db_instance.rds_instance.address}:${var.db_port}/${var.db_name}"
      DB_USERNAME   = var.db_username
      DB_PASSWORD   = var.db_password
      EMAIL_API_KEY = var.sendgrid_api_key
      EMAIL_FROM    = var.email_from_address
      SNS_TOPIC_ARN = aws_sns_topic.email_topic.arn
    }
  }

  tags = merge(var.tags, { Name = "email-lambda-${var.unique_suffix}" })
}

# Lambda Permission for SNS Invocation
resource "aws_lambda_permission" "sns_permission" {
  statement_id  = "AllowSNSInvocation"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.email_lambda.arn
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.email_topic.arn
}

# SNS Subscription to Lambda
resource "aws_sns_topic_subscription" "lambda_subscription" {
  topic_arn = aws_sns_topic.email_topic.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.email_lambda.arn
}
