resource "aws_launch_template" "asg_launch_template" {
  name          = "csye6225_asg-${var.unique_suffix}"
  image_id      = var.custom_ami
  instance_type = "t2.micro"
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_instance_profile.name
  }

  monitoring {
    enabled = true
  }
  vpc_security_group_ids = [aws_security_group.application_sg.id]
  key_name               = var.key_pair_name
  user_data = base64encode(<<-EOF
  #!/bin/bash

    sudo apt update -y
    sudo apt install -y unzip jq

    # Download and install AWS CLI v2
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
    rm -rf awscliv2.zip aws/

    # Fetch Database Credentials from Secrets Manager
    DB_SECRET=$(aws secretsmanager get-secret-value --secret-id db-password-dev --query 'SecretString' --output text)
    DB_USERNAME=$(echo $DB_SECRET | jq -r '.username')
    DB_PASSWORD=$(echo $DB_SECRET | jq -r '.password')

    # Fetch Email Service Credentials from Secrets Manager
    EMAIL_SECRET=$(aws secretsmanager get-secret-value --secret-id email-credentials-dev --query 'SecretString' --output text)
    EMAIL_API_KEY=$(echo $EMAIL_SECRET | jq -r '.api_key')
    EMAIL_FROM=$(echo $EMAIL_SECRET | jq -r '.from')

    # Set Environment Variables
    echo "spring.datasource.url=jdbc:mysql://${aws_db_instance.rds_instance.address}:${var.db_port}/${var.db_name}" | sudo tee -a /etc/environment
    echo "spring.datasource.username=$DB_USERNAME" | sudo tee -a /etc/environment
    echo "spring.datasource.password=$DB_PASSWORD" | sudo tee -a /etc/environment
    echo "amazonProperties.clientRegion=us-east-1" | sudo tee -a /etc/environment
    echo "sendgrid.api-key=$EMAIL_API_KEY" | sudo tee -a /etc/environment
    echo "EMAIL_FROM=$EMAIL_FROM" | sudo tee -a /etc/environment
    echo "S3_BUCKET=${aws_s3_bucket.log_bucket.bucket}" | sudo tee -a /etc/environment
    echo "SNS_TOPIC_ARN=${aws_sns_topic.email_topic.arn}" | sudo tee -a /etc/environment

    # Reload Environment Variables
    source /etc/environment
EOF
  )

}


resource "aws_autoscaling_group" "autoscaling" {
  name             = "autoscaling-group-${var.unique_suffix}"
  min_size         = 1
  max_size         = 5
  desired_capacity = 1
  launch_template {
    id      = aws_launch_template.asg_launch_template.id
    version = "$Latest"
  }
  vpc_zone_identifier       = aws_subnet.public[*].id
  health_check_type         = "EC2"
  health_check_grace_period = 300
  target_group_arns         = [aws_lb_target_group.target_group.arn]

  tag {
    key                 = "Name"
    value               = "web-app-instance-${var.unique_suffix}"
    propagate_at_launch = true
  }
}

# Scale up policy
resource "aws_autoscaling_policy" "scale_up_policy" {
  name                   = "Web-server-scale-up-${var.unique_suffix}"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.autoscaling.name
}

# Scale down policy
resource "aws_autoscaling_policy" "scale_down_policy" {
  name                   = "Web-server-scale-down-${var.unique_suffix}"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.autoscaling.name
}
