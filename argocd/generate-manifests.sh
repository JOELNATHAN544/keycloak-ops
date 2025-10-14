#!/bin/bash

# Script to generate ArgoCD manifests from templates using environment variables
# This is an alternative to using Kustomize overlays

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_info() {
    echo -e "${BLUE}→ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

echo "=========================================="
echo "ArgoCD Manifest Generator"
echo "=========================================="
echo ""

# Check if .env file exists
if [ ! -f ".env" ]; then
    print_error ".env file not found!"
    echo ""
    echo "Please create a .env file from .env.example:"
    echo "  cp .env.example .env"
    echo "  # Then edit .env with your values"
    echo ""
    exit 1
fi

print_info "Loading environment variables from .env..."

# Load environment variables
set -a
source .env
set +a

print_success "Environment variables loaded"

# Verify required variables
REQUIRED_VARS=(
    "REPO_URL"
    "GITHUB_USERNAME"
    "DEV_TARGET_REVISION"
    "PROD_TARGET_REVISION"
    "K8S_SERVER"
    "DEV_NAMESPACE"
    "PROD_NAMESPACE"
    "DEV_DOMAIN"
    "PROD_DOMAIN"
)

echo ""
print_info "Verifying required variables..."

missing_vars=()
for var in "${REQUIRED_VARS[@]}"; do
    if [ -z "${!var}" ]; then
        missing_vars+=("$var")
    fi
done

if [ ${#missing_vars[@]} -ne 0 ]; then
    print_error "Missing required environment variables:"
    for var in "${missing_vars[@]}"; do
        echo "  - $var"
    done
    echo ""
    echo "Please update your .env file with all required variables"
    exit 1
fi

print_success "All required variables are set"

# Display configuration
echo ""
echo "Configuration:"
echo "  Repository: $REPO_URL"
echo "  Dev Branch: $DEV_TARGET_REVISION"
echo "  Prod Tag:   $PROD_TARGET_REVISION"
echo "  Dev Domain: $DEV_DOMAIN"
echo "  Prod Domain: $PROD_DOMAIN"
echo ""

# Create output directory
print_info "Creating output directory..."
mkdir -p argocd/generated

# Check if envsubst is available
if ! command -v envsubst &> /dev/null; then
    print_warning "envsubst not found, using sed as fallback..."
    USE_SED=true
else
    USE_SED=false
fi

# Generate manifests
echo ""
print_info "Generating manifests..."

if [ "$USE_SED" = true ]; then
    # Use sed as fallback
    
    # Generate keycloak-dev.yaml
    sed -e "s|\${REPO_URL}|${REPO_URL}|g" \
        -e "s|\${DEV_TARGET_REVISION}|${DEV_TARGET_REVISION}|g" \
        -e "s|\${K8S_SERVER}|${K8S_SERVER}|g" \
        -e "s|\${DEV_NAMESPACE}|${DEV_NAMESPACE}|g" \
        -e "s|\${DEV_DOMAIN}|${DEV_DOMAIN}|g" \
        argocd/templates/keycloak-dev.template.yaml > argocd/generated/keycloak-dev.yaml
    
    # Generate keycloak-prod.yaml
    sed -e "s|\${REPO_URL}|${REPO_URL}|g" \
        -e "s|\${PROD_TARGET_REVISION}|${PROD_TARGET_REVISION}|g" \
        -e "s|\${K8S_SERVER}|${K8S_SERVER}|g" \
        -e "s|\${PROD_NAMESPACE}|${PROD_NAMESPACE}|g" \
        -e "s|\${PROD_DOMAIN}|${PROD_DOMAIN}|g" \
        argocd/templates/keycloak-prod.template.yaml > argocd/generated/keycloak-prod.yaml
else
    # Use envsubst
    envsubst < argocd/templates/keycloak-dev.template.yaml > argocd/generated/keycloak-dev.yaml
    envsubst < argocd/templates/keycloak-prod.template.yaml > argocd/generated/keycloak-prod.yaml
fi

print_success "Generated keycloak-dev.yaml"
print_success "Generated keycloak-prod.yaml"

# Copy project definition (no substitution needed)
print_info "Copying keycloak project definition..."
cp argocd/projects/keycloak-project.yaml argocd/generated/keycloak-project.yaml
print_success "Copied keycloak-project.yaml"

echo ""
echo "=========================================="
print_success "All Manifests Generated Successfully!"
echo "=========================================="
echo ""
echo "Generated files are in: argocd/generated/"
echo ""
echo "Files created:"
echo "  - argocd/generated/keycloak-project.yaml"
echo "  - argocd/generated/keycloak-dev.yaml"
echo "  - argocd/generated/keycloak-prod.yaml"
echo ""
echo "Next steps:"
echo ""
echo "1. Review the generated manifests:"
echo "   cat argocd/generated/keycloak-dev.yaml"
echo ""
echo "2. Apply to your cluster:"
echo "   kubectl apply -f argocd/generated/keycloak-project.yaml"
echo "   kubectl apply -f argocd/generated/keycloak-dev.yaml"
echo "   kubectl apply -f argocd/generated/keycloak-prod.yaml"
echo ""
echo "3. Or apply all at once:"
echo "   kubectl apply -f argocd/generated/"
echo ""
echo "4. Check application status:"
echo "   kubectl get applications -n argocd"
echo ""