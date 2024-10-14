# modules/route53/main.tf

resource "aws_route53_zone" "main" {
  name = var.domain_name

  tags = {
    Environment = var.environment
  }

  lifecycle {
    ignore_changes = all
  }
}

locals {
  zone_id = aws_route53_zone.main.zone_id
}

resource "aws_route53_record" "root_a" {
  zone_id = local.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = var.load_balancer_dns_name
    zone_id                = var.load_balancer_zone_id
    evaluate_target_health = true
  }

  lifecycle {
    ignore_changes = all
  }
}

resource "aws_route53_record" "www_cname" {
  zone_id = local.zone_id
  name    = "www.${var.domain_name}"
  type    = "CNAME"
  ttl     = 300
  records = [var.domain_name]

  lifecycle {
    ignore_changes = all
  }
}



