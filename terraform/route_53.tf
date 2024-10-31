resource "aws_route53_record" "dev_subdomain" {
  zone_id = var.dev_hosted_zone_id # ID of the dev Route 53 hosted zone
  name    = "dev.${var.domain_name}"
  type    = "A"
  ttl     = 60
  records = [aws_instance.app_instance.public_ip]
}

resource "aws_route53_record" "demo_subdomain" {
  zone_id = var.demo_hosted_zone_id # ID of the demo Route 53 hosted zone
  name    = "demo.${var.domain_name}"
  type    = "A"
  ttl     = 60
  records = [aws_instance.app_instance.public_ip]
}