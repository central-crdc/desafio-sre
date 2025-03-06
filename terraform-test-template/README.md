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
