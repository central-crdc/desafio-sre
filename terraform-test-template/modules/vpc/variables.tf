variable "name" {
  description = "Nome do VPC"
  type        = string
}

variable "cidr" {
  description = "CIDR block para o VPC"
  type        = string
}

variable "azs" {
  description = "Zonas de disponibilidade para usar"
  type        = list(string)
}

variable "private_subnets" {
  description = "Lista de CIDRs de subnets privadas"
  type        = list(string)
}

variable "public_subnets" {
  description = "Lista de CIDRs de subnets públicas"
  type        = list(string)
}

variable "enable_nat_gateway" {
  description = "Habilitar NAT Gateway para VPC"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Usar um único NAT Gateway para todas as subnets privadas"
  type        = bool
  default     = false
}

variable "environment" {
  description = "Ambiente para implantação"
  type        = string
}

variable "tags" {
  description = "Tags adicionais para o VPC"
  type        = map(string)
  default     = {}
}
