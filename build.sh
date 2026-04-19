#!/bin/bash
set -e

REGISTRY="localhost:5000"
DOCKER_APPS=("anniversary" "celebration" "devops-app" "ganesh_harini" "tom_and_jerry")
K8S_APPS=("anniversary" "celebration" "devops-app" "ganesh-harini" "tom-and-jerry")

echo "=== Pointing Docker to Minikube's daemon ==="
eval $(minikube docker-env)

echo "=== Building images inside Minikube Docker ==="
for APP in "${DOCKER_APPS[@]}"; do
  echo "--- Building $APP ---"
  docker build --build-arg APP_NAME=$APP \
    -t $APP:latest \
    -f docker/Dockerfile .
done

echo "=== Deploying to Kubernetes ==="
export KUBECONFIG=/var/lib/jenkins/.kube/config
kubectl config use-context minikube

for YAML in k8s/*.yaml; do
  kubectl apply -f $YAML --validate=false
done

echo "=== Rollout status ==="
for APP in "${K8S_APPS[@]}"; do
  kubectl rollout status deployment/$APP --timeout=180s
done

echo "=== Done! Apps running ==="
kubectl get pods -o wide
kubectl get svc