include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "${get_path_to_repo_root()}/modules/vpc"
}

inputs = {
  name = "prod-vpc"
  
  # Especificações para o VPC em prod/us-east-1
  cidr = "10.2.0.0/16"
  
  public_subnets = [
    "10.2.1.0/24",
    "10.2.2.0/24",
    "10.2.3.0/24",
    "10.2.4.0/24"
  ]
  
  private_subnets = [
    "10.2.10.0/24",
    "10.2.11.0/24",
    "10.2.12.0/24",
    "10.2.13.0/24"
  ]
  
  enable_nat_gateway = true
  single_nat_gateway = false
  
  tags = {
    Module = "VPC"
    Compliance = "PCI-DSS"
    CriticalData = "yes"
  }
}
