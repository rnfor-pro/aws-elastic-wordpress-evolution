#!/usr/bin/env bash
set -euo pipefail
terraform init
terraform plan
terraform apply -auto-approve
