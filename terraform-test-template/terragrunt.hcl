# Root terragrunt.hcl - Configurações globais

locals {
  # Parse o path relativo para obter o ambiente e a região
  path_parts = compact(split("/", path_relative_to_include()))
  
  # Os primeiros níveis do caminho devem ser ambiente/região
  environment = try(local.path_parts[0], "")
  region      = try(local.path_parts[1], "")
  
  # Carregar configurações específicas por conta
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  
  # Carregar variáveis específicas do ambiente
  env_vars = try(
    read_terragrunt_config(find_in_parent_folders("env.hcl")),
    { inputs = {} }
  )
  
  # Carregar variáveis específicas da região
  region_vars = try(
    read_terragrunt_config(find_in_parent_folders("region.hcl")),
    { inputs = {} }
  )
  
  # Extrair informações da conta
  account_name = local.account_vars.locals.account_name
  account_id   = local.account_vars.locals.account_id
  
  # Construir tags comuns a serem aplicadas a todos os recursos
  common_tags = {
    Environment = local.environment
    Region      = local.region
    ManagedBy   = "Terragrunt"
    Owner       = "SRE-Team"
  }
}

# Configuração remota de estado
remote_state {
  backend = "s3"
  
  config = {
    encrypt        = true
    bucket         = "terraform-states-${local.account_id}"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "us-east-1"  # Região para o bucket de state
    dynamodb_table = "terraform-locks"
    
    # Use o perfil assumido para a conta específica
    role_arn       = "arn:aws:iam::${local.account_id}:role/TerragruntStateAccess"
  }
  
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

# Gere provider.tf para cada componente
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOT
provider "aws" {
  region = "\${local.region}"
  
  # Configura o papel a assumir para a conta alvo
  assume_role {
    role_arn = "arn:aws:iam::\${local.account_id}:role/TerraformProvisionRole"
  }
  
  default_tags {
    tags = \${jsonencode(local.common_tags)}
  }
}
EOT
}

# Defina inputs globais que serão mergeados a todos os componentes
inputs = merge(
  local.account_vars.inputs,
  local.env_vars.inputs,
  local.region_vars.inputs,
)
