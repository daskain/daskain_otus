# #! /bin/bash

#VAR
PROJECT_FOLDER="/home/daskain/git/dev/otus/daskain_otus"

#get cred
# yc managed-kubernetes cluster get-credentials \
#     --folder-name $K8S_FOLDER_NAME \
#     --cloud-id $K8S_CLOUD_ID \
#     --external $K8S_MASTER_NODE \
#     --force

cd $(echo $PROJECT_FOLDER/kuber/manifests)

echo "Install Ingress Contorller"
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.1.0/deploy/static/provider/cloud/deploy.yaml

# echo "Create admin account"
# kubectl apply -f gitlab-admin-service-account.yaml

# echo "Registration runner role"
# kubectl apply -f gitlab-runner-role.yaml

echo "Create admin account"
kubectl create clusterrolebinding gitlab-admin --clusterrole=cluster-admin --group=system:serviceaccounts

echo "Create runner"
helm upgrade --namespace default gitlab-runner -f values.yaml gitlab/gitlab-runner -i

#GET token
token=$(kubectl -n kube-system get secrets -o json | \
jq -r '.items[] | select(.metadata.name | startswith("gitlab-admin")) | .data.token' | \
base64 --decode)
echo $token
