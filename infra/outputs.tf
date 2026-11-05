# Les valeurs affichées après "terraform apply".

output "vpc_id" {
  description = "Identifiant du VPC de Waxtan"
  value       = aws_vpc.principal.id
}

output "subnet_public_id" {
  description = "Identifiant du subnet public"
  value       = aws_subnet.public.id
}

output "security_group_web_id" {
  description = "Identifiant du Security Group web"
  value       = aws_security_group.web.id
}
