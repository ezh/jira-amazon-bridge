resource "aws_route53_record" "this" {
  name    = "${var.prefix}${var.name}"
  records = aws_elasticsearch_domain.this.*.endpoint
  zone_id = var.hosted_zone_id
  ttl     = "300"
  type    = "CNAME"
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.this.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 300
  type            = each.value.type
  zone_id         = var.hosted_zone_id
}

data "aws_route53_zone" "this" {
  zone_id = var.hosted_zone_id
}
