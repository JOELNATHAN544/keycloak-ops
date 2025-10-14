# ArgoCD Setup for Keycloak Deployment

This directory contains ArgoCD configurations for automated Keycloak deployment using GitOps principles.

## Overview

We use ArgoCD to automatically deploy Keycloak from our Helm chart based on Git branches and tags:

- **Development**: Tracks `main` branch → deploys to `keycloak-dev` namespace
- **Production**: Tracks version tags (e.g., `v1.0.0`) → deploys to `keycloak-prod` namespace

## Directory Structure

```
argocd/
├── README.md                          # This file
├── setup.sh                           # Interactive setup script (RECOMMENDED)
├── installation/
│   └── install-argocd.sh             # ArgoCD installation script
├── projects/
│   └── keycloak-project.yaml         # ArgoCD project definition
├── base/                              # Base configurations (for Kustomize)
│   ├── keycloak-dev.yaml
│   └── keycloak-prod.yaml
├── overlays/                          # Personal customizations (git-ignored)
│   └── personal/                      # Your personal fork settings
│       ├── kustomization.yaml
│       └── README.md
├── templates/                         # Templates for envsubst method (alternative)
│   ├── keycloak-dev.template.yaml
│   └── keycloak-prod.template.yaml
└── generate-manifests.sh              # Script for template method (alternative)
```

## Quick Start (Recommended Method)

### Option 1: Using Kustomize (RECOMMENDED)

This is the cleanest approach and most widely used in production.

#### Step 1: Run the setup script

```bash
chmod +x argocd/setup.sh
./argocd/setup.sh
```

The script will:
- Ask for your GitHub username
- Generate personalized Kustomize overlays
- Create configuration specific to your fork

#### Step 2: Install ArgoCD (if not already installed)

```bash
chmod +x argocd/installation/install-argocd.sh
./argocd/installation/install-argocd.sh
```

#### Step 3: Deploy using Kustomize

```bash
# Deploy everything at once
kubectl apply -k argocd/overlays/personal/

# Or deploy individually
kubectl apply -f argocd/projects/keycloak-project.yaml
kubectl kustomize argocd/overlays/personal/ | kubectl apply -f -
```

### Option 2: Using Environment Variables (Alternative)

If you prefer using environment variables:

#### Step 1: Create your .env file

```bash
cp .env.example .env
# Edit .env with your GitHub username and settings
```

#### Step 2: Generate manifests

```bash
chmod +x argocd/generate-manifests.sh
./argocd/generate-manifests.sh
```

#### Step 3: Deploy

```bash
kubectl apply -f argocd/projects/keycloak-project.yaml
kubectl apply -f argocd/generated/
```

## For Team Members Working on Forks

Each team member should:

1. **Fork the main repository** to your GitHub account
2. **Clone your fork**:
   ```bash
   git clone https://github.com/YOUR_USERNAME/keycloak-ops
   cd keycloak-ops
   ```

3. **Run the setup script**:
   ```bash
   ./argocd/setup.sh
   ```
   Enter your GitHub username when prompted.

4. **The `overlays/personal/` directory is git-ignored**, so your personal settings won't conflict with others.

5. **Deploy to your cluster**:
   ```bash
   kubectl apply -k argocd/overlays/personal/
   ```

## Prerequisites

- Kubernetes cluster (v1.19+)
- kubectl configured
- Git repository access
- (Optional) Kustomize CLI for viewing manifests

## Accessing ArgoCD UI

```bash
# Port forward
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Get admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

Open: https://localhost:8080
- Username: `admin`
- Password: (from command above)

## Workflow

### Development Deployment
1. Commit changes to `main` branch in your fork
2. Push to GitHub: `git push origin main`
3. ArgoCD detects changes within 3 minutes
4. Automatically syncs to `keycloak-dev` namespace
5. Self-heals if manual changes are made to the cluster

### Production Deployment
1. Create a Git tag: 
   ```bash
   git tag -a v1.0.0 -m "Release v1.0.0"
   git push origin v1.0.0
   ```
2. Update `keycloak-prod.yaml` (or template) to reference the new tag
3. Apply the changes:
   ```bash
   kubectl apply -k argocd/overlays/personal/
   ```
4. ArgoCD syncs to `keycloak-prod` namespace

## Monitoring

### Check Application Status
```bash
kubectl get applications -n argocd
```

### View Application Details
```bash
kubectl describe application keycloak-dev -n argocd
```

### Using ArgoCD CLI
```bash
# Install CLI
curl -sSL -o argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
chmod +x argocd
sudo mv argocd /usr/local/bin/

# Login
argocd login localhost:8080

# List apps
argocd app list

# Get app details
argocd app get keycloak-dev

# Manual sync
argocd app sync keycloak-dev

# Watch sync progress
argocd app wait keycloak-dev
```

## Troubleshooting

### Application Not Syncing
```bash
# Check application status
kubectl describe application keycloak-dev -n argocd

# Check ArgoCD logs
kubectl logs -n argocd deployment/argocd-application-controller

# Force refresh
argocd app get keycloak-dev --refresh
```

### Repository Access Issues
Make sure your repository is accessible:
```bash
# For private repos, add SSH key or access token
argocd repo add https://github.com/YOUR_USERNAME/keycloak-ops \
  --username YOUR_USERNAME \
  --password YOUR_TOKEN
```

### Reset Admin Password
```bash
kubectl -n argocd patch secret argocd-secret \
  -p '{"stringData": {"admin.password": "'$(htpasswd -bnBC 10 "" NewPassword | tr -d ':\n')'"}}'
```

## Best Practices

1. ✅ **Use Kustomize overlays** for personal forks (cleanest approach)
2. ✅ **Always use tags for production** deployments
3. ✅ **Test in dev first** before promoting to production
4. ✅ **Never commit** `.env` or `overlays/personal/` to Git
5. ✅ **Monitor deployments** using ArgoCD UI or CLI
6. ✅ **Use Git** for all changes, not direct kubectl commands
7. ✅ **Document** any custom configurations

## Contributing

When working on this project:

1. **Base configurations** go in `argocd/base/`
2. **Personal settings** go in `argocd/overlays/personal/` (git-ignored)
3. **Documentation updates** should be committed to the main repo
4. **Never hardcode** personal repository URLs in base files

## References

- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [Kustomize Documentation](https://kubectl.docs.kubernetes.io/references/kustomize/)
- [Helm Chart Repository](../helm-chart/)
- [Main Project README](../README.md)

## Support

For issues or questions:
1. Check the troubleshooting section above
2. Review ArgoCD logs
3. Open an issue in the repository
4. Contact the team on your communication channel