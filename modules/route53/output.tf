# modules/route53/outputs.tf

output "certificate_status" {
  value = aws_acm_certificate.main.status
}

output "zone_id" {
  value = data.aws_route53_zone.existing.zone_id
}

output "name_servers" {
  value = data.aws_route53_zone.existing.name_servers
}

output "certificate_arn" {
  value = aws_acm_certificate.main.arn
}

output "certificate_validation_records" {
  value = [for record in aws_route53_record.cert_validation : record]
}