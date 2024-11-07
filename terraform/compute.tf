resource "random_integer" "random_index" {
  min = 0
  max = length(var.public_subnet_cidrs) - 1
}

resource "aws_instance" "app_instance" {
  ami                         = var.custom_ami
  instance_type               = "t2.micro"
  subnet_id                   = element(aws_subnet.public[*].id, random_integer.random_index.result)
  vpc_security_group_ids      = [aws_security_group.application_sg.id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ec2_instance_profile.name

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
    echo "S3_BUCKET=${aws_s3_bucket.log_bucket.bucket}" | sudo tee -a /etc/environment
    source /etc/environment
  EOF

  tags = merge(var.tags, { Name = "web-app-instance-${var.unique_suffix}" })
}
