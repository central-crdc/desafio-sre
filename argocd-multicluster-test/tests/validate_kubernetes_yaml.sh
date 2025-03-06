#!/bin/bash

# Encontra todos os arquivos YAML no diretório atual e subdiretórios
yamls=$(find . -name "*.yaml" -o -name "*.yml")

# Verifica cada arquivo YAML
for yaml in $yamls; do
  echo "Validando $yaml..."
  kubectl apply --dry-run=client -f "$yaml"
  if [ $? -ne 0 ]; then
    echo "Erro: A validação de $yaml falhou."
    exit 1
  fi
done

echo "Validação de todos os arquivos YAML concluída com sucesso."

