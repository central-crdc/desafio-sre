#!/bin/bash

# Verifica se o diretório 'modules' existe
if [ ! -d "./modules" ]; then
  echo "Erro: O diretório 'modules' não existe."
  exit 1
fi

# Verifica se há pelo menos um módulo dentro do diretório 'modules'
if [ -z "$(ls -A ./modules)" ]; then
  echo "Erro: Nenhum módulo encontrado no diretório 'modules'."
  exit 1
fi

echo "Estrutura de módulos verificada com sucesso."

