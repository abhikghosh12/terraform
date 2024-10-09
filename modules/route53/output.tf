# modules/route53/outputs.tf

output "certificate_status" {
  value = aws_acm_certificate.main.status
}


output "certificate_arn" {
  value = aws_acm_certificate.main.arn
}

output "certificate_validation_records" {
  value = [for record in aws_route53_record.cert_validation : record]
}

output "zone_id" {
  value = local.zone_id
}

output "name_servers" {
  value = var.create_route53_zone ? aws_route53_zone.main[0].name_servers : data.aws_route53_zone.existing[0].name_servers
}
