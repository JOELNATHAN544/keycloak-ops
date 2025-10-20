# Local Development and Testing

This directory contains configuration files for local development and testing with Kind (Kubernetes in Docker).

## Files

### kind-config.yaml

Kind cluster configuration for running Keycloak locally. This is a minimal configuration for development and testing purposes.

**Usage:**

```bash
# Create Kind cluster
kind create cluster --name keycloak-demo --config local/kind-config.yaml

# Delete Kind cluster
kind delete cluster --name keycloak-demo
```

## PostgreSQL Configuration

PostgreSQL is configured in `kustomize/base/postgres.yaml` using the official `postgres:15-alpine` image.

**Note:** For production use, consider using an external managed database service (AWS RDS, GCP Cloud SQL, Azure Database).

## Quick Start Options

### Option 1: Kustomize Deployment (Recommended)

**Fastest way to get started** - Deploys both Keycloak and PostgreSQL:

```bash
# 1. Create Kind cluster
kind create cluster --name keycloak-demo --config local/kind-config.yaml

# 2. Deploy with Kustomize (includes postgres)
kubectl apply -k kustomize/base/

# 3. Watch pods starting (Ctrl+C to exit)
kubectl get pods -n keycloak -w

# 4. Port-forward to access Keycloak
kubectl port-forward -n keycloak svc/keycloak 8080:8080

# 5. Access Keycloak at http://localhost:8080
# Username: admin
# Password: admin123
```

### Option 2: Helm Deployment

If you prefer Helm:

```bash
# 1. Create Kind cluster
kind create cluster --name keycloak-demo --config local/kind-config.yaml

# 2. Deploy PostgreSQL from Kustomize base
kubectl apply -f kustomize/base/namespace.yaml
kubectl apply -f kustomize/base/postgres.yaml

# 3. Wait for PostgreSQL to be ready
kubectl wait --for=condition=ready pod/postgres-0 -n keycloak --timeout=300s

# 4. Deploy Keycloak with Helm
helm install keycloak ./helm/keycloak \
  --namespace keycloak \
  --set ingress.enabled=false \
  --set keycloak.admin.password=admin123 \
  --set keycloak.database.password=keycloak123

# 5. Wait for Keycloak to start (takes 2-3 minutes)
kubectl get pods -n keycloak -w

# 6. Port-forward to access Keycloak
kubectl port-forward -n keycloak svc/keycloak 8080:8080

# 7. Access Keycloak at http://localhost:8080
# Username: admin
# Password: admin123
```

### Option 3: Multi-Environment Testing

Test different environments:

```bash
# 1. Create Kind cluster
kind create cluster --name keycloak-demo --config local/kind-config.yaml

# 2. Deploy base, dev, and prod environments
kubectl apply -k kustomize/base/
kubectl apply -k kustomize/overlays/dev/
kubectl apply -k kustomize/overlays/production/

# 3. Check all deployments
kubectl get pods -A | grep keycloak

# 4. Access each environment
# Base:  kubectl port-forward -n keycloak svc/keycloak 8080:8080
# Dev:   kubectl port-forward -n keycloak-dev svc/keycloak-dev 8081:8080
# Prod:  kubectl port-forward -n keycloak-prod svc/keycloak-prod 8082:8080
```

## Verify Deployment

```bash
# Check that pods are ready (should show 1/1 for Keycloak pods)
kubectl get pods -n keycloak

# View Keycloak logs
kubectl logs -n keycloak -l app.kubernetes.io/name=keycloak --tail=50

# Test health endpoints
kubectl exec -n keycloak deployment/keycloak -- curl -s http://localhost:9000/health/ready
```

## Cleanup

```bash
# Delete the Kind cluster (removes everything)
kind delete cluster --name keycloak-demo
```
