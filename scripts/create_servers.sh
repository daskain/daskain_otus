#! /bin/bash

PROJECT_FOLDER="/home/daskain/git/dev/otus/daskain_otus"
K8S_CLOUD_ID="b1galktnqd8s8ij5diff"
K8S_FOLDER_NAME="default"
K8S_MASTER_NODE="k8s-yc"

echo "Create k8s servers"
cd $(echo $PROJECT_FOLDER/terraform/k8s)
terraform init 
terraform apply --auto-approve 

#get cred
yc managed-kubernetes cluster get-credentials \
    --folder-name $K8S_FOLDER_NAME \
    --cloud-id $K8S_CLOUD_ID \
    --external $K8S_MASTER_NODE \
    --force

echo "Create infra servers"
cd $(echo $PROJECT_FOLDER/terraform/infra/prod/)
terraform init 
terraform apply --auto-approve

# sleep 10s

echo "Install env to infra"
cd $(echo $PROJECT_FOLDER/ansible)
ansible-playbook playbooks/prepare_infra.yml
