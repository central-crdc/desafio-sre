#!/bin/bash

# Inicializa o Terraform
terraform init -backend=false

# Valida os arquivos de configuração do Terraform
terraform validate

if [ $? -ne 0 ]; then
  echo "Erro: A validação do Terraform falhou."
  exit 1
fi

echo "Validação do Terraform concluída com sucesso."

