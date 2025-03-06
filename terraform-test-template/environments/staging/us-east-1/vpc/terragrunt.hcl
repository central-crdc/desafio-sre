include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "${get_path_to_repo_root()}/modules/vpc"
}

inputs = {
  name = "staging-vpc"
  
  # Especificações para o VPC em staging/us-east-1
  cidr = "10.1.0.0/16"
  
  public_subnets = [
    "10.1.1.0/24",
    "10.1.2.0/24",
    "10.1.3.0/24"
  ]
  
  private_subnets = [
    "10.1.10.0/24",
    "10.1.11.0/24",
    "10.1.12.0/24"
  ]
  
  enable_nat_gateway = true
  single_nat_gateway = false
  
  tags = {
    Module = "VPC"
  }
}
