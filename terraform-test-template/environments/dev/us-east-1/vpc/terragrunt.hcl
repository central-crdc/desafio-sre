include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "${get_path_to_repo_root()}/modules/vpc"
}

inputs = {
  name = "dev-vpc"
  
  # Especificações para o VPC em dev/us-east-1
  cidr = "10.0.0.0/16"
  
  public_subnets = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24"
  ]
  
  private_subnets = [
    "10.0.10.0/24",
    "10.0.11.0/24",
    "10.0.12.0/24"
  ]
  
  enable_nat_gateway = true
  single_nat_gateway = true
  
  tags = {
    Module = "VPC"
  }
}
