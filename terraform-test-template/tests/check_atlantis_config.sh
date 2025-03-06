#!/bin/bash
# Verifica se o Atlantis está configurado para diferentes workflows
workflows=$(grep -c "workflow: terragrunt-" atlantis.yaml)
if [ $workflows -ge 3 ]; then
  echo "Atlantis configured with multiple workflows"
  exit 0
else
  echo "Atlantis not properly configured for multiple environments"
  exit 1
fi
