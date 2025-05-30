resource "aws_lb" "application_lb" {
  name               = "application-lb-${var.unique_suffix}"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.load_balancer_sg.id]
  subnets            = aws_subnet.public[*].id
}

resource "aws_lb_target_group" "target_group" {
  name     = "app-target-group-${var.unique_suffix}"
  port     = var.application_port
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/healthz"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.application_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}

resource "aws_acm_certificate" "dev_ssl_cert" {
  domain_name       = var.subdomain_name
  validation_method = "DNS"

  tags = {
    Name = "Dev SSL Certificate"
  }

  provisioner "local-exec" {
    command = "sleep 15"
  }
}

resource "aws_lb_listener" "https_listener_dev" {
  load_balancer_arn = aws_lb.application_lb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.dev_ssl_cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}



