#!/bin/bash
# Verifica a estrutura básica do ArgoCD

# Verificar se a base do ArgoCD está configurada
if [ -d "argocd-config/base" ] && [ -f "argocd-config/base/argocd-cm.yaml" ]; then
  echo "ArgoCD base configuration found"
else
  echo "Missing ArgoCD base configuration"
  exit 1
fi

# Verificar se existem overlays para os diferentes ambientes
if [ -d "argocd-config/overlays/dev" ] && [ -d "argocd-config/overlays/prod" ]; then
  echo "ArgoCD environment overlays found"
else
  echo "Missing ArgoCD environment overlays"
  exit 1
fi

# Verificar configuração de bootstrap
if [ -d "cluster-bootstrap" ] && [ -f "cluster-bootstrap/dev/argocd-application-set.yaml" ]; then
  echo "Cluster bootstrap configuration found"
else
  echo "Missing cluster bootstrap configuration"
  exit 1
fi

echo "ArgoCD structure check passed"
exit 0
