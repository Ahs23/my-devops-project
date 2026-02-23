#!/bin/bash
set -e

echo "=== Kubernetes Deployment Script ==="
echo "Deploying armanshaikh23/my-devops-app to Kubernetes cluster"

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo "ERROR: kubectl is not installed"
    exit 1
fi

# Check cluster connection
echo "Checking Kubernetes cluster connection..."
if ! kubectl cluster-info &> /dev/null; then
    echo "ERROR: Cannot connect to Kubernetes cluster"
    exit 1
fi

# Get current context
CURRENT_CONTEXT=$(kubectl config current-context)
echo "Connected to cluster: $CURRENT_CONTEXT"

# Apply Kubernetes manifests
echo "Applying Kubernetes manifests..."

echo "1. Deploying application..."
kubectl apply -f deployment.yml

echo "2. Creating service..."
kubectl apply -f service.yml

echo "3. Setting up autoscaling..."
kubectl apply -f hpa.yml

# Wait for deployment to be ready
echo "Waiting for deployment to be ready..."
kubectl rollout status deployment/my-devops-app -n default --timeout=5m

# Get deployment info
echo ""
echo "=== Deployment Status ==="
kubectl get deployments -n default
kubectl get pods -n default -l app=my-devops-app
kubectl get svc -n default

# Get service endpoint
echo ""
echo "=== Service Information ==="
SERVICE_IP=$(kubectl get svc my-devops-app-service -n default -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "pending")
if [ "$SERVICE_IP" != "pending" ]; then
    echo "Application is accessible at: http://$SERVICE_IP"
else
    echo "LoadBalancer IP is still pending. Check back in a few moments."
    echo "Use: kubectl get svc my-devops-app-service -n default"
fi

echo ""
echo "✓ Kubernetes deployment completed successfully!"
