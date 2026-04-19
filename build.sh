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

# FIX 1: Point to jenkins user's kubeconfig (not $HOME which may resolve wrong)
export KUBECONFIG=/var/lib/jenkins/.kube/config

kubectl config use-context minikube

for YAML in k8s/*.yaml; do
  # FIX 2: Add --validate=false to avoid openapi download errors
  kubectl apply -f $YAML --validate=false
done

echo "=== Rollout status ==="
for APP in "${APPS[@]}"; do
  # FIX 3: deployment name must match your YAML metadata.name exactly
  kubectl rollout status deployment/$APP --timeout=120s
done

echo "=== Done! Apps running ==="
kubectl get pods -o wide
kubectl get svc