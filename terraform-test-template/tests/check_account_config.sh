#!/bin/bash
# Verifica se há configuração para as 3 contas
if [ -f accounts/dev/account.hcl ] && [ -f accounts/staging/account.hcl ] && [ -f accounts/prod/account.hcl ]; then
  echo "All three accounts configured"
  exit 0
else
  echo "Missing account configurations"
  exit 1
fi
