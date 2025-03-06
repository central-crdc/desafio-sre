#!/bin/bash

# Verifica se o diretório 'overlays' existe
if [ ! -d "./overlays" ]; then
  echo "Erro: O diretório 'overlays' não existe."
  exit 1
fi

# Verifica se há pelo menos um overlay dentro do diretório 'overlays'
if [ -z "$(ls -A ./overlays)" ]; then
  echo "Erro: Nenhum overlay encontrado no diretório 'overlays'."
  exit 1
fi

echo "Estrutura de overlays do Kustomize verificada com sucesso."

