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