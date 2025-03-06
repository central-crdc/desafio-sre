locals {
  account_name = "staging"
  account_id   = "444455556666"  # ID da conta de staging
}

inputs = {
  account_name = "staging"
  domain       = "staging.example.com"
  
  # Configurações de VPC específicas para staging
  vpc_cidr     = "10.1.0.0/16"
  
  # Configurações de EKS específicas para staging
  eks_version  = "1.25"
  node_groups = {
    standard = {
      min_size     = 2
      max_size     = 6
      desired_size = 3
      instance_types = ["t3.large"]
    }
  }
}
