#!/bin/bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "========================================"
echo " Enterprise Linux CI Validation"
echo "========================================"

echo
echo "[1/3] Terraform formatting check"
cd "$PROJECT_ROOT/terraform"
terraform fmt -check -recursive

echo
echo "[2/3] Terraform configuration validation"
terraform validate

echo
echo "[3/3] Ansible syntax validation"
cd "$PROJECT_ROOT/ansible"

for playbook in playbooks/*.yml; do
    echo "Checking: $playbook"
    /usr/local/bin/ansible-playbook "$playbook" --syntax-check
done

echo
echo "========================================"
echo " CI VALIDATION: PASS"
echo "========================================"
