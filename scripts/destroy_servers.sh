#! /bin/bash
PROJECT_FOLDER="/home/daskain/git/dev/otus/daskain_otus"

echo "Destroy infra servers"
cd $(echo $PROJECT_FOLDER/terraform/infra/prod/)
terraform init 
terraform destroy --auto-approve

echo "Destroy k8s servers"
cd $(echo $PROJECT_FOLDER/terraform/k8s)
terraform init 
terraform destroy --auto-approve 
