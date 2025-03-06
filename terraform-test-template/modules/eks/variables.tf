variable "cluster_name" {
  description = "Nome do cluster EKS"
  type        = string
}

variable "cluster_version" {
  description = "Versão do Kubernetes para o cluster EKS"
  type        = string
}

variable "vpc_id" {
  description = "ID do VPC onde o cluster será criado"
  type        = string
}

variable "subnet_ids" {
  description = "Lista de IDs de subnets para o cluster"
  type        = list(string)
}

variable "node_groups" {
  description = "Mapa de configurações de node groups do EKS"
  type        = any
  default     = {}
}

variable "environment" {
  description = "Ambiente para implantação"
  type        = string
}

variable "tags" {
  description = "Tags adicionais para o cluster EKS"
  type        = map(string)
  default     = {}
}
