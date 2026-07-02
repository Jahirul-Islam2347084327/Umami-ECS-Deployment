resource "aws_acm_certificate" "certificate" {
  domain_name       = var.custom-url
  validation_method = "DNS"
}

resource "aws_route53_zone" "zone" {
  name         = var.custom-url
}

resource "aws_route53_record" "acm" {
  for_each = {
    for dvo in aws_acm_certificate.certificate.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.zone.zone_id
}

resource "aws_route53_record" "alb" {
  zone_id = aws_route53_zone.zone.id
  type = "A"
  name = var.custom-url
alias {
    name                   = var.alb-dns-name
    zone_id                = var.alb-zone-id
    evaluate_target_health = true                   
  }
depends_on = [aws_acm_certificate_validation.validation]
}

resource "aws_acm_certificate_validation" "validation" {
  certificate_arn         = aws_acm_certificate.certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.acm : record.fqdn]
}
