#!/bin/bash

# Setup script for ArgoCD Keycloak deployment
# This script helps configure your personal fork settings

set -e

echo "=========================================="
echo "ArgoCD Keycloak Setup"
echo "=========================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to print colored output
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Check if running in correct directory
if [ ! -d "argocd" ]; then
    print_error "Please run this script from the root of the repository"
    exit 1
fi

# Get GitHub username
echo "Enter your GitHub username:"
read -r GITHUB_USERNAME

if [ -z "$GITHUB_USERNAME" ]; then
    print_error "GitHub username cannot be empty"
    exit 1
fi

# Construct repository URL
REPO_URL="https://github.com/${GITHUB_USERNAME}/keycloak-ops"

echo ""
print_warning "Repository URL will be set to: $REPO_URL"
echo "Is this correct? (y/n)"
read -r CONFIRM

if [ "$CONFIRM" != "y" ]; then
    echo "Setup cancelled"
    exit 0
fi

# Create overlays directory structure
echo ""
echo "Creating overlay configuration..."
mkdir -p argocd/overlays/personal

# Create kustomization.yaml with user's repo
cat > argocd/overlays/personal/kustomization.yaml <<EOF
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

# Base configurations
resources:
  - ../../base/keycloak-dev.yaml
  - ../../base/keycloak-prod.yaml
  - ../../projects/keycloak-project.yaml

# Patches to customize for your fork
patches:
  - target:
      kind: Application
      name: keycloak-dev
    patch: |-
      - op: replace
        path: /spec/source/repoURL
        value: ${REPO_URL}
  
  - target:
      kind: Application
      name: keycloak-prod
    patch: |-
      - op: replace
        path: /spec/source/repoURL
        value: ${REPO_URL}
EOF

print_success "Kustomization file created!"

# Create .gitignore for overlays/personal if it doesn't exist
if [ ! -f "argocd/overlays/.gitignore" ]; then
    cat > argocd/overlays/.gitignore <<EOF
# Ignore personal overlays (each user has their own)
personal/
EOF
    print_success ".gitignore created for personal overlays"
fi

# Create README for personal overlay
cat > argocd/overlays/personal/README.md <<EOF
# Personal Overlay Configuration

This overlay is customized for: **${GITHUB_USERNAME}**

Repository URL: \`${REPO_URL}\`

## Usage

### Deploy using kubectl with Kustomize:
\`\`\`bash
kubectl apply -k argocd/overlays/personal/
\`\`\`

### View generated manifests:
\`\`\`bash
kubectl kustomize argocd/overlays/personal/
\`\`\`

## Note
This directory is git-ignored and specific to your fork.
Do not commit this to the main repository.
EOF

print_success "Personal overlay README created!"

echo ""
echo "=========================================="
print_success "Setup Complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Review the generated files in: argocd/overlays/personal/"
echo "2. Deploy ArgoCD project and applications:"
echo "   kubectl apply -k argocd/overlays/personal/"
echo ""
echo "3. Or deploy individually:"
echo "   kubectl apply -f argocd/projects/keycloak-project.yaml"
echo "   kubectl kustomize argocd/overlays/personal/ | kubectl apply -f -"
echo ""