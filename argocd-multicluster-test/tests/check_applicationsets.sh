#!/bin/bash

# Verifica se o arquivo ApplicationSet existe
if [ ! -f "./applicationset.yaml" ]; then
  echo "Erro: O arquivo 'applicationset.yaml' não existe."
  exit 1
fi

# Valida a sintaxe do arquivo ApplicationSet
kubectl apply --dry-run=client -f ./applicationset.yaml

if [ $? -ne 0 ]; then
  echo "Erro: A validação do 'applicationset.yaml' falhou."
  exit 1
fi

echo "Validação do ApplicationSet concluída com sucesso."

