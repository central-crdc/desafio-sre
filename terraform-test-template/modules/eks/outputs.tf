output "cluster_id" {
  description = "Nome do cluster EKS"
  value       = module.eks.cluster_id
}

output "cluster_endpoint" {
  description = "Endpoint para o servidor da API do EKS"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "ID do security group criado para o cluster EKS"
  value       = module.eks.cluster_security_group_id
}

output "oidc_provider_arn" {
  description = "ARN do provedor OIDC do cluster"
  value       = module.eks.oidc_provider_arn
}
