inputs = {
  environment = "prod"
  
  # Variáveis específicas do ambiente prod
  enable_vpc_flow_logs = true
  enable_detailed_monitoring = true
  
  # Ajustes de segurança para prod
  allow_public_ingress = false
}
