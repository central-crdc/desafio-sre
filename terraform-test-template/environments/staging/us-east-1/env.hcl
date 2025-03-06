inputs = {
  environment = "staging"
  
  # Variáveis específicas do ambiente staging
  enable_vpc_flow_logs = true
  enable_detailed_monitoring = true
  
  # Ajustes de segurança para staging
  allow_public_ingress = false
}
