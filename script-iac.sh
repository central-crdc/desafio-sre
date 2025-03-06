#!/bin/bash
# Script para criar estrutura de teste Terragrunt com Atlantis e múltiplas contas AWS

# Criação da estrutura de diretórios
echo "Criando estrutura de diretórios..."
mkdir -p terraform-test-template
cd terraform-test-template

# Criar diretórios principais
mkdir -p accounts/{dev,staging,prod}
mkdir -p modules/{vpc,eks}
mkdir -p environments/dev/us-east-1/{vpc,eks}
mkdir -p environments/staging/us-east-1/{vpc,eks}
mkdir -p environments/prod/us-east-1/{vpc,eks}

# Criar o README.md
echo "Criando README.md..."
cat > README.md << 'EOF'
# Teste de Terragrunt com Atlantis - Múltiplas Contas AWS

## Visão Geral
Este teste avalia sua capacidade de trabalhar com Terragrunt e Atlantis em um ambiente multi-conta AWS, seguindo o princípio DRY.

## Requisitos
- Conhecimento de Terraform e Terragrunt
- Familiaridade com o Atlantis como ferramenta de CI/CD para infraestrutura
- Experiência com gerenciamento de múltiplas contas AWS
- Compreensão da estrutura de módulos no modelo CloudPosse

## Tarefas

### 1. Completar a Configuração Terragrunt
Complete os arquivos Terragrunt faltantes para implementar uma estrutura DRY que gerencia:
- VPCs separadas em múltiplas contas e regiões
- Clusters EKS em cada ambiente
- Diferentes configurações por ambiente (dev, staging, prod)

### 2. Configurar o Atlantis
Modifique o arquivo `atlantis.yaml` para:
- Detectar os projetos Terragrunt corretamente
- Configurar workflows diferentes por ambiente
- Implementar a troca dinâmica de funções IAM para diferentes contas AWS

### 3. Implementar Lógica de Assume Role
Implemente a lógica de "assume role" para permitir que o Atlantis provisionasse recursos em diferentes contas AWS a partir de uma conta centralizada.

### 4. Adicionar Validações e Políticas
Adicione validações no Terragrunt para garantir:
- Nomes de recursos padronizados
- Tags obrigatórias em todos os recursos
- Limites de políticas de segurança apropriados para cada ambiente

## Entrega
- Complete todos os arquivos Terragrunt e Terraform conforme necessário
- Documente suas decisões e abordagem em um arquivo SOLUTION.md
- Certifique-se de que a estrutura siga as melhores práticas DRY
- Garanta que o Atlantis possa processar corretamente sua configuração
EOF

# Criar o terragrunt.hcl na raiz
echo "Criando terragrunt.hcl raiz..."
cat > terragrunt.hcl << 'EOF'
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
EOF

# Criar atlantis.yaml
echo "Criando atlantis.yaml..."
cat > atlantis.yaml << 'EOF'
version: 3
automerge: false
parallel_plan: true
parallel_apply: false

projects:
# Dev environment
- name: dev-us-east-1-vpc
  dir: environments/dev/us-east-1/vpc
  workflow: terragrunt-dev
  autoplan:
    when_modified: ["*.hcl", "*.tf"]
    enabled: true

- name: dev-us-east-1-eks
  dir: environments/dev/us-east-1/eks
  workflow: terragrunt-dev
  autoplan:
    when_modified: ["*.hcl", "*.tf"]
    enabled: true

# Staging environment
- name: staging-us-east-1-vpc
  dir: environments/staging/us-east-1/vpc
  workflow: terragrunt-staging
  autoplan:
    when_modified: ["*.hcl", "*.tf"]
    enabled: true

# Production environment
- name: prod-us-east-1-vpc
  dir: environments/prod/us-east-1/vpc
  workflow: terragrunt-prod
  autoplan:
    when_modified: ["*.hcl", "*.tf"]
    enabled: true

# Define workflows específicos por ambiente com diferentes approvers
workflows:
  terragrunt-dev:
    plan:
      steps:
      - env:
          name: AWS_PROFILE
          value: dev
        run: terragrunt plan -no-color -out=$PLANFILE
    apply:
      steps:
      - env:
          name: AWS_PROFILE
          value: dev
        run: terragrunt apply -no-color $PLANFILE

  terragrunt-staging:
    plan:
      steps:
      - env:
          name: AWS_PROFILE
          value: staging
        run: terragrunt plan -no-color -out=$PLANFILE
    apply:
      steps:
      - env:
          name: AWS_PROFILE
          value: staging
        run: terragrunt apply -no-color $PLANFILE

  terragrunt-prod:
    plan:
      steps:
      - env:
          name: AWS_PROFILE
          value: prod
        run: terragrunt plan -no-color -out=$PLANFILE
    apply:
      steps:
      - env:
          name: AWS_PROFILE
          value: prod
        run: terragrunt apply -no-color $PLANFILE
      requires:
        approvals: 2
EOF

# Criar configuração da conta dev
echo "Criando accounts/dev/account.hcl..."
cat > accounts/dev/account.hcl << 'EOF'
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
EOF

# Criar configuração da conta staging
echo "Criando accounts/staging/account.hcl..."
cat > accounts/staging/account.hcl << 'EOF'
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
EOF

# Criar configuração da conta prod
echo "Criando accounts/prod/account.hcl..."
cat > accounts/prod/account.hcl << 'EOF'
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
EOF

# Criar configurações do ambiente dev
echo "Criando configurações de ambiente para dev..."
cat > environments/dev/us-east-1/env.hcl << 'EOF'
inputs = {
  environment = "dev"
  
  # Variáveis específicas do ambiente dev
  enable_vpc_flow_logs = false
  enable_detailed_monitoring = false
  
  # Ajustes de segurança para dev
  allow_public_ingress = true
}
EOF

cat > environments/dev/us-east-1/region.hcl << 'EOF'
inputs = {
  region = "us-east-1"
  
  # Variáveis específicas da região us-east-1
  azs = ["us-east-1a", "us-east-1b", "us-east-1c"]
  
  # Configurações regionais específicas
  instance_type_override = "t3.medium"
}
EOF

# Criar terragrunt.hcl para VPC no ambiente dev
echo "Criando environments/dev/us-east-1/vpc/terragrunt.hcl..."
cat > environments/dev/us-east-1/vpc/terragrunt.hcl << 'EOF'
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
EOF

# Criar terragrunt.hcl para EKS no ambiente dev
echo "Criando environments/dev/us-east-1/eks/terragrunt.hcl..."
cat > environments/dev/us-east-1/eks/terragrunt.hcl << 'EOF'
include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "${get_path_to_repo_root()}/modules/eks"
}

dependency "vpc" {
  config_path = "../vpc"
}

inputs = {
  cluster_name = "dev-eks"
  cluster_version = "1.25"
  
  vpc_id = dependency.vpc.outputs.vpc_id
  subnet_ids = dependency.vpc.outputs.private_subnets
  
  # Configuração dos node groups
  node_groups = {
    standard = {
      desired_capacity = 2
      max_capacity     = 4
      min_capacity     = 2
      instance_types   = ["t3.medium"]
      disk_size        = 50
    }
  }
  
  tags = {
    Module = "EKS"
  }
}
EOF

# Criar arquivos de módulo VPC
echo "Criando arquivos do módulo VPC..."
cat > modules/vpc/main.tf << 'EOF'
provider "aws" {
  # A configuração do provider virá do terragrunt
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"
  
  name = var.name
  cidr = var.cidr
  
  azs             = var.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets
  
  enable_nat_gateway = var.enable_nat_gateway
  single_nat_gateway = var.single_nat_gateway
  
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = merge(
    var.tags,
    {
      Terraform   = "true"
      Environment = var.environment
    }
  )
}
EOF

cat > modules/vpc/variables.tf << 'EOF'
variable "name" {
  description = "Nome do VPC"
  type        = string
}

variable "cidr" {
  description = "CIDR block para o VPC"
  type        = string
}

variable "azs" {
  description = "Zonas de disponibilidade para usar"
  type        = list(string)
}

variable "private_subnets" {
  description = "Lista de CIDRs de subnets privadas"
  type        = list(string)
}

variable "public_subnets" {
  description = "Lista de CIDRs de subnets públicas"
  type        = list(string)
}

variable "enable_nat_gateway" {
  description = "Habilitar NAT Gateway para VPC"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Usar um único NAT Gateway para todas as subnets privadas"
  type        = bool
  default     = false
}

variable "environment" {
  description = "Ambiente para implantação"
  type        = string
}

variable "tags" {
  description = "Tags adicionais para o VPC"
  type        = map(string)
  default     = {}
}
EOF

cat > modules/vpc/outputs.tf << 'EOF'
output "vpc_id" {
  description = "ID do VPC criado"
  value       = module.vpc.vpc_id
}

output "private_subnets" {
  description = "Lista de IDs das subnets privadas"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "Lista de IDs das subnets públicas"
  value       = module.vpc.public_subnets
}

output "nat_public_ips" {
  description = "Lista de IPs públicos dos NAT Gateways"
  value       = module.vpc.nat_public_ips
}
EOF

# Criar arquivos de módulo EKS
echo "Criando arquivos do módulo EKS..."
cat > modules/eks/main.tf << 'EOF'
provider "aws" {
  # A configuração do provider virá do terragrunt
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 18.0"
  
  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  
  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids
  
  eks_managed_node_group_defaults = {
    disk_size                  = 50
    instance_types             = ["t3.medium"]
    ami_type                   = "AL2_x86_64"
    iam_role_attach_cni_policy = true
  }
  
  eks_managed_node_groups = var.node_groups
  
  tags = merge(
    var.tags,
    {
      Terraform   = "true"
      Environment = var.environment
    }
  )
}
EOF

cat > modules/eks/variables.tf << 'EOF'
variable "cluster_name" {
  description = "Nome do cluster EKS"
  type        = string
}

variable "cluster_version" {
  description = "Versão do Kubernetes para o cluster EKS"
  type        = string
}

variable "vpc_id" {
  description = "ID do VPC onde o cluster será criado"
  type        = string
}

variable "subnet_ids" {
  description = "Lista de IDs de subnets para o cluster"
  type        = list(string)
}

variable "node_groups" {
  description = "Mapa de configurações de node groups do EKS"
  type        = any
  default     = {}
}

variable "environment" {
  description = "Ambiente para implantação"
  type        = string
}

variable "tags" {
  description = "Tags adicionais para o cluster EKS"
  type        = map(string)
  default     = {}
}
EOF

cat > modules/eks/outputs.tf << 'EOF'
output "cluster_id" {
  description = "Nome do cluster EKS"
  value       = module.eks.cluster_id
}

output "cluster_endpoint" {
  description = "Endpoint para o servidor da API do EKS"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "ID do security group criado para o cluster EKS"
  value       = module.eks.cluster_security_group_id
}

output "oidc_provider_arn" {
  description = "ARN do provedor OIDC do cluster"
  value       = module.eks.oidc_provider_arn
}
EOF

# Criar ambiente staging e prod
echo "Criando ambientes staging e prod (estrutura similar)..."

# Staging: env.hcl
cat > environments/staging/us-east-1/env.hcl << 'EOF'
inputs = {
  environment = "staging"
  
  # Variáveis específicas do ambiente staging
  enable_vpc_flow_logs = true
  enable_detailed_monitoring = true
  
  # Ajustes de segurança para staging
  allow_public_ingress = false
}
EOF

# Staging: region.hcl
cat > environments/staging/us-east-1/region.hcl << 'EOF'
inputs = {
  region = "us-east-1"
  
  # Variáveis específicas da região us-east-1
  azs = ["us-east-1a", "us-east-1b", "us-east-1c"]
  
  # Configurações regionais específicas
  instance_type_override = "t3.large"
}
EOF

# Staging: VPC terragrunt.hcl
cat > environments/staging/us-east-1/vpc/terragrunt.hcl << 'EOF'
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
EOF

# Production: env.hcl
cat > environments/prod/us-east-1/env.hcl << 'EOF'
inputs = {
  environment = "prod"
  
  # Variáveis específicas do ambiente prod
  enable_vpc_flow_logs = true
  enable_detailed_monitoring = true
  
  # Ajustes de segurança para prod
  allow_public_ingress = false
}
EOF

# Production: region.hcl
cat > environments/prod/us-east-1/region.hcl << 'EOF'
inputs = {
  region = "us-east-1"
  
  # Variáveis específicas da região us-east-1
  azs = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d"]
  
  # Configurações regionais específicas
  instance_type_override = "m5.large"
}
EOF

# Production: VPC terragrunt.hcl
cat > environments/prod/us-east-1/vpc/terragrunt.hcl << 'EOF'
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
EOF

# Criar scripts de verificação para autograding
echo "Criando scripts de verificação para autograding..."
mkdir -p tests

cat > tests/check_dry_principle.sh << 'EOF'
#!/bin/bash
# Verifica se o candidato está usando corretamente o find_in_parent_folders
count=$(grep -r "find_in_parent_folders" --include="*.hcl" . | wc -l)
if [ $count -ge 3 ]; then
  echo "DRY principle correctly applied using find_in_parent_folders"
  exit 0
else
  echo "Not enough usage of find_in_parent_folders to implement DRY"
  exit 1
fi
EOF

cat > tests/check_account_config.sh << 'EOF'
#!/bin/bash
# Verifica se há configuração para as 3 contas
if [ -f accounts/dev/account.hcl ] && [ -f accounts/staging/account.hcl ] && [ -f accounts/prod/account.hcl ]; then
  echo "All three accounts configured"
  exit 0
else
  echo "Missing account configurations"
  exit 1
fi
EOF

cat > tests/check_atlantis_config.sh << 'EOF'
#!/bin/bash
# Verifica se o Atlantis está configurado para diferentes workflows
workflows=$(grep -c "workflow: terragrunt-" atlantis.yaml)
if [ $workflows -ge 3 ]; then
  echo "Atlantis configured with multiple workflows"
  exit 0
else
  echo "Atlantis not properly configured for multiple environments"
  exit 1
fi
EOF

# Tornar os scripts executáveis
chmod +x tests/*.sh

echo "Estrutura do teste Terragrunt criada com sucesso em ./terraform-test-template"
echo "Você pode usar este diretório como template para o seu teste de SRE."
