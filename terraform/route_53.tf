resource "aws_route53_record" "subdomain" {
  zone_id = var.aws_profile == "dev" ? var.dev_hosted_zone_id : var.demo_hosted_zone_id
  name    = "${var.aws_profile}.${var.domain_name}"
  type    = "A"
  alias {
    name                   = aws_lb.application_lb.dns_name
    zone_id                = aws_lb.application_lb.zone_id
    evaluate_target_health = true
  }
}

# Add DNS Validation Records
resource "aws_route53_record" "acm_validation" {
  for_each = {
    for dvo in aws_acm_certificate.dev_ssl_cert.domain_validation_options : dvo.domain_name => dvo
  }
  zone_id = var.aws_profile == "dev" ? var.dev_hosted_zone_id : var.demo_hosted_zone_id
  name    = each.value.resource_record_name
  type    = each.value.resource_record_type
  records = [each.value.resource_record_value]
  ttl     = 300
}
