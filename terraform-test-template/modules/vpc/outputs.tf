output "vpc_id" {
  description = "ID do VPC criado"
  value       = module.vpc.vpc_id
}

output "private_subnets" {
  description = "Lista de IDs das subnets privadas"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "Lista de IDs das subnets públicas"
  value       = module.vpc.public_subnets
}

output "nat_public_ips" {
  description = "Lista de IPs públicos dos NAT Gateways"
  value       = module.vpc.nat_public_ips
}
