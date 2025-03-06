#!/bin/bash
# Verifica se o candidato está usando corretamente o find_in_parent_folders
count=$(grep -r "find_in_parent_folders" --include="*.hcl" . | wc -l)
if [ $count -ge 3 ]; then
  echo "DRY principle correctly applied using find_in_parent_folders"
  exit 0
else
  echo "Not enough usage of find_in_parent_folders to implement DRY"
  exit 1
fi
