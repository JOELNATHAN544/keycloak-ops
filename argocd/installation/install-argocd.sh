#!/bin/bash

# Script to install ArgoCD on Kubernetes cluster

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}→ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

echo "=========================================="
echo "Installing ArgoCD"
echo "=========================================="
echo ""

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    print_error "kubectl is not installed or not in PATH"
    exit 1
fi

# Check if cluster is accessible
if ! kubectl cluster-info &> /dev/null; then
    print_error "Cannot connect to Kubernetes cluster"
    echo "Please ensure kubectl is configured correctly"
    exit 1
fi

print_success "Kubernetes cluster is accessible"

# Create namespace
print_info "Creating argocd namespace..."
kubectl create namespace argocd 2>/dev/null || echo "Namespace argocd already exists"

# Install ArgoCD
print_info "Installing ArgoCD components..."
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for ArgoCD to be ready
print_info "Waiting for ArgoCD to be ready (this may take a few minutes)..."
kubectl wait --for=condition=available --timeout=600s deployment/argocd-server -n argocd
kubectl wait --for=condition=available --timeout=600s deployment/argocd-repo-server -n argocd
kubectl wait --for=condition=available --timeout=600s deployment/argocd-application-controller -n argocd

print_success "ArgoCD deployed successfully!"

# Get initial admin password
echo ""
echo "=========================================="
print_success "Installation Complete!"
echo "=========================================="
echo ""
echo "Initial Admin Credentials:"
echo "  Username: admin"
echo -n "  Password: "
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" 2>/dev/null | base64 -d
echo ""
echo ""
echo "To access ArgoCD UI:"
echo "  1. Run port-forward:"
echo "     kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo ""
echo "  2. Open browser:"
echo "     https://localhost:8080"
echo ""
echo "  3. Login with credentials above"
echo ""
echo "To install ArgoCD CLI (optional):"
echo "  curl -sSL -o argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64"
echo "  chmod +x argocd"
echo "  sudo mv argocd /usr/local/bin/"
echo ""
echo "  # Then login:"
echo "  argocd login localhost:8080"
echo ""