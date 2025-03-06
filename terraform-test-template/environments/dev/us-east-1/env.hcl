inputs = {
  environment = "dev"
  
  # Variáveis específicas do ambiente dev
  enable_vpc_flow_logs = false
  enable_detailed_monitoring = false
  
  # Ajustes de segurança para dev
  allow_public_ingress = true
}
