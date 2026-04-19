#!/bin/bash
set -e

REGISTRY="localhost:5000"
APPS=("anniversary" "celebration" "devops-app" "ganesh_harini" "tom_and_jerry")

echo "=== Building and pushing Docker images ==="
for APP in "${APPS[@]}"; do
  echo "--- Building $APP ---"
  docker build --build-arg APP_NAME=$APP \
    -t $REGISTRY/$APP:latest \
    -f docker/Dockerfile .
  docker push $REGISTRY/$APP:latest
done

echo "=== Deploying to Kubernetes ==="
# Point kubectl to minikube
export KUBECONFIG=$HOME/.kube/config
kubectl config use-context minikube

for YAML in k8s/*.yaml; do
  kubectl apply -f $YAML
done

echo "=== Rollout status ==="
for APP in "${APPS[@]}"; do
  kubectl rollout status deployment/$APP --timeout=120s
done

echo "=== Done! Apps running ==="
kubectl get pods -o wide
kubectl get svc