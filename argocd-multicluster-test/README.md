# Teste de ArgoCD Multi-Cluster para EKS

## Visão Geral
Este teste avalia sua capacidade de configurar e gerenciar uma estrutura GitOps com ArgoCD para múltiplos clusters EKS em diferentes contas AWS.

## Requisitos
- Conhecimento de Kubernetes e EKS
- Experiência com ArgoCD e princípios GitOps
- Familiaridade com Kustomize para gerenciamento de variações entre ambientes
- Compreensão de estratégias de implantação em múltiplos clusters

## Tarefas

### 1. Configuração do ArgoCD
Configure o ArgoCD para gerenciar múltiplos clusters EKS com:
- Uma instalação de ArgoCD centralizada no cluster de ferramentas
- Configuração de acesso seguro a todos os clusters gerenciados
- Implementação de autenticação OIDC com AWS IAM

### 2. Estrutura de Aplicações
Implemente uma estrutura de aplicações que:
- Suporte implantações em múltiplos ambientes (dev, staging, prod)
- Utilize Kustomize para gerenciar diferenças entre ambientes
- Configure promoção automatizada entre ambientes

### 3. Componentes de Plataforma
Configure componentes de plataforma para todos os clusters:
- Controladores de Ingress
- Gerenciamento de certificados
- Monitoramento e observabilidade
- Logging centralizado

### 4. Segurança e Isolamento
Implemente práticas de segurança como:
- Políticas de rede para isolamento
- RBAC para acesso granular
- Integração com Secrets Management (AWS Secrets Manager ou Vault)

## Entrega
- Complete todos os arquivos YAML/Kustomize conforme necessário
- Documente sua abordagem e decisões em um arquivo SOLUTION.md
- Inclua instruções de como um administrador configuraria a integração com EKS
- Adicione detalhes sobre como promover aplicações entre ambientes
