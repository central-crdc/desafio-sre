#!/bin/bash

# Verifica se o arquivo de documentação da solução existe
if [ ! -f "./SOLUTION.md" ]; then
  echo "Erro: O arquivo 'SOLUTION.md' não existe."
  exit 1
fi

# Verifica se o arquivo de documentação não está vazio
if [ ! -s "./SOLUTION.md" ]; then
  echo "Erro: O arquivo 'SOLUTION.md' está vazio."
  exit 1
fi

echo "Documentação da solução verificada com sucesso."

