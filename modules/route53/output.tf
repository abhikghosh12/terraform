# modules/route53/outputs.tf

output "certificate_status" {
  value = aws_acm_certificate.main.status
}

output "zone_id" {
  value = aws_route53_zone.main.zone_id
}

output "name_servers" {
  value = aws_route53_zone.main.name_servers
}

output "certificate_arn" {
  value = aws_acm_certificate.main.arn
}