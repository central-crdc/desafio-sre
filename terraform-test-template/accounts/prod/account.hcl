locals {
  account_name = "prod"
  account_id   = "777788889999"  # ID da conta de produção
}

inputs = {
  account_name = "prod"
  domain       = "example.com"
  
  # Configurações de VPC específicas para produção
  vpc_cidr     = "10.2.0.0/16"
  
  # Configurações de EKS específicas para produção
  eks_version  = "1.25"
  node_groups = {
    standard = {
      min_size     = 3
      max_size     = 10
      desired_size = 5
      instance_types = ["m5.large"]
    }
    spot = {
      min_size     = 1
      max_size     = 5
      desired_size = 2
      instance_types = ["m5.large", "m4.large", "m5a.large"]
      capacity_type = "SPOT"
    }
  }
}
