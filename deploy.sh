#!/bin/bash

# Deploy script for Kyma
set -e

NAMESPACE=${1:-cap-bookstore}
IMAGE_TAG=${2:-latest}
REGISTRY=${3:-{YOUR_DOCKER_REGISTRY_HERE}}

echo "Deploying bookstore to Kyma namespace: ${NAMESPACE}"
echo "Using image: ${REGISTRY}/bookstore:${IMAGE_TAG}"

# Check if kubectl is available and cluster is accessible
if ! command -v kubectl &> /dev/null; then
    echo "Error: kubectl is not installed or not in PATH"
    exit 1
fi

if ! kubectl cluster-info &> /dev/null; then
    echo "Error: Cannot connect to Kubernetes cluster. Please check your kubeconfig"
    exit 1
fi

# Create namespace if it doesn't exist
kubectl create namespace ${NAMESPACE} --dry-run=client -o yaml | kubectl apply -f -

# Enable Istio sidecar injection
kubectl label namespace ${NAMESPACE} istio-injection=enabled --overwrite

# Update image in deployment
sed "s|bookstore:latest|${REGISTRY}/bookstore:${IMAGE_TAG}|g" k8s/deployment.yaml > k8s/deployment-updated.yaml

# Check if required files exist
required_files=("k8s/configmap-postgres.yaml" "k8s/deployment.yaml" "k8s/service.yaml" "k8s/apirule.yaml" "k8s/authorizationpolicy.yaml" "k8s/virtualservice.yaml")
for file in "${required_files[@]}"; do
    if [ ! -f "$file" ]; then
        echo "Error: Required file $file not found!"
        exit 1
    fi
done

# Apply all manifests
echo "Applying Kubernetes manifests..."
kubectl apply -n ${NAMESPACE} -f k8s/configmap-postgres.yaml
kubectl apply -n ${NAMESPACE} -f k8s/deployment.yaml
kubectl apply -n ${NAMESPACE} -f k8s/service.yaml
kubectl apply -n ${NAMESPACE} -f k8s/virtualservice.yaml
kubectl apply -n ${NAMESPACE} -f k8s/apirule.yaml
kubectl apply -n ${NAMESPACE} -f k8s/authorizationpolicy.yaml

# Wait for deployment
echo "Waiting for deployment to be ready..."
kubectl rollout status deployment/bookstore-deployment -n ${NAMESPACE}

# Clean up temporary file
rm -f k8s/deployment-updated.yaml

echo "Deployment completed successfully!"
echo "Access your application at: https://bookstore-cap.{YOUR_CLUSTER_DOMAIN_HERE}"
echo ""
echo "Useful commands:"
echo "  kubectl get pods -n ${NAMESPACE}"
echo "  kubectl logs -f deployment/bookstore-deployment -n ${NAMESPACE}"
echo "  kubectl port-forward service/bookstore-service 8080:80 -n ${NAMESPACE}"
echo "  kubectl get ingress -n ${NAMESPACE}"