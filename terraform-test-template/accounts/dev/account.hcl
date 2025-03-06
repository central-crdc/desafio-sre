locals {
  account_name = "dev"
  account_id   = "111122223333"  # ID da conta de desenvolvimento
}

inputs = {
  account_name = "dev"
  domain       = "dev.example.com"
  
  # Configurações de VPC específicas para desenvolvimento
  vpc_cidr     = "10.0.0.0/16"
  
  # Configurações de EKS específicas para desenvolvimento
  eks_version  = "1.25"
  node_groups = {
    standard = {
      min_size     = 2
      max_size     = 4
      desired_size = 2
      instance_types = ["t3.medium"]
    }
  }
}
