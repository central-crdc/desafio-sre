# Instruções de Implementação ArgoCD Multi-Cluster

## Pré-requisitos
- Múltiplos clusters EKS em diferentes contas AWS
- Permissões IAM para o ArgoCD acessar os clusters 
- Repositório Git configurado

## Passos de Implementação

### 1. Configurar o ArgoCD no cluster principal
```bash
# Aplicar a configuração base
kubectl apply -k argocd-config/overlays/cluster-tools

# Verificar se o ArgoCD está rodando
kubectl get pods -n argocd
