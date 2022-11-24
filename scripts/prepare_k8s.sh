#! /bin/bash


PROJECT_FOLDER="/home/daskain/git/dev/otus/daskain_otus"

cd $(echo $PROJECT_FOLDER/kuber/manifests)

echo "Install Ingress Contorller"
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.1.0/deploy/static/provider/cloud/deploy.yaml

echo "Create admin account"
kubectl create clusterrolebinding gitlab-admin --clusterrole=cluster-admin --group=system:serviceaccounts

echo "Create runner"
helm upgrade --namespace default gitlab-runner -f values.yaml gitlab/gitlab-runner -i

echo "Create monitoring"
kubectl create namespace monitoring

echo "Create logging"
kubectl create namespace logging

#GET token
token=$(kubectl -n kube-system get secrets -o json | \
jq -r '.items[] | select(.metadata.name | startswith("gitlab-admin")) | .data.token' | \
base64 --decode)
echo $token
