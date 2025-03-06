#!/bin/bash
# Verifica configuração multi-cluster

# Verificar se existem configurações para múltiplos clusters
count=$(grep -r "cluster:" --include="*.yaml" . | wc -l)
if [ $count -ge 3 ]; then
  echo "Multiple cluster configurations found"
else
  echo "Not enough cluster configurations for multi-cluster setup"
  exit 1
fi

# Verificar ApplicationSets para deployments multi-cluster
if grep -q "ApplicationSet" applications/appsets/workloads-appset.yaml; then
  echo "ApplicationSet for multi-cluster deployment found"
else
  echo "Missing ApplicationSet configuration for multi-cluster deployment"
  exit 1
fi

echo "Multi-cluster configuration check passed"
exit 0
