#!/bin/bash

terraform apply -var-file="secrets.tfvars"

if [ $? -ne 0 ]; then
    echo "Terraform apply failed. Running terraform destroy..."
    terraform destroy -var-file="secrets.tfvars" -auto-approve 
fi