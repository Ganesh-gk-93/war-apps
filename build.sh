#!/bin/bash
set -e

export MINIKUBE_HOME=/var/lib/jenkins/.minikube
export KUBECONFIG=/var/lib/jenkins/.kube/config
export DOCKER_TLS_VERIFY="1"
export DOCKER_HOST="tcp://192.168.49.2:2376"
export DOCKER_CERT_PATH="/var/lib/jenkins/.minikube/certs"

K8S_APPS=("anniversary" "celebration" "devops-app" "ganesh-harini" "tom-and-jerry")

echo "=== Building images directly inside Minikube Docker ==="
docker build --build-arg APP_NAME=anniversary   -t anniversary:latest   -f docker/Dockerfile .
docker build --build-arg APP_NAME=celebration   -t celebration:latest   -f docker/Dockerfile .
docker build --build-arg APP_NAME=devops-app    -t devops-app:latest    -f docker/Dockerfile .
docker build --build-arg APP_NAME=ganesh_harini -t ganesh-harini:latest -f docker/Dockerfile .
docker build --build-arg APP_NAME=tom_and_jerry -t tom-and-jerry:latest -f docker/Dockerfile .

echo "=== Deploying to Kubernetes ==="
kubectl config use-context minikube

for YAML in k8s/*.yaml; do
  kubectl apply -f $YAML --validate=false
done

echo "=== Rollout status ==="
for APP in "${K8S_APPS[@]}"; do
  kubectl rollout status deployment/$APP --timeout=180s
done

echo "=== Done! ==="
kubectl get pods -o wide
kubectl get svc