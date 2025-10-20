# Keycloak-ops

Production-ready Keycloak deployment configurations for Kubernetes using Helm and Kustomize.

## Overview

This repository provides two deployment methods for Keycloak on Kubernetes:

- **Kustomize** (Primary): GitOps-friendly manifests with environment-specific overlays
- **Helm Charts**: Full-featured, configurable Helm chart for flexible deployments

**✅ Status:** All deployments tested and working with Keycloak 26.4.0

## Prerequisites

### Required Tools

#### 1. **Docker**
Required for local development with Kind and container operations.

- **Linux**: [Install Docker Engine](https://docs.docker.com/engine/install/#server)
- **macOS**: [Install Docker Desktop for Mac](https://docs.docker.com/desktop/install/mac-install/)
- **Windows**: [Install Docker Desktop for Windows](https://docs.docker.com/desktop/install/windows-install/)

#### 2. **kubectl**
Kubernetes command-line tool for cluster management.

- **Linux**: [Install kubectl on Linux](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/)
- **macOS**: [Install kubectl on macOS](https://kubernetes.io/docs/tasks/tools/install-kubectl-macos/)
- **Windows**: [Install kubectl on Windows](https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/)

#### 3. **Helm** (for Helm deployments)
Kubernetes package manager - version 3.x required.

- **All platforms**: [Installing Helm](https://helm.sh/docs/intro/install/)

#### 4. **Kustomize** (for Kustomize deployments)
Kubernetes native configuration management.

- **All platforms**: [Installing Kustomize](https://kubectl.docs.kubernetes.io/installation/kustomize/)
- **Note**: Kustomize is also built into `kubectl` (use `kubectl apply -k`)

#### 5. **Kind** (optional, for local development)
Kubernetes in Docker - for local testing.

- **All platforms**: [Installing Kind](https://kind.sigs.k8s.io/docs/user/quick-start/#installation)

### Infrastructure Requirements

- **Kubernetes cluster** v1.24 or higher
- kubectl configured and authenticated to your cluster
- (Optional) **NGINX Ingress Controller** for ingress support
- (Optional) **cert-manager** for automated TLS certificate management

## Features

- ✅ **Keycloak 26.4.0** (Quarkus-based Keycloak.X)
- ✅ Production-ready deployment with HA
- ✅ PostgreSQL database integration (postgres:15-alpine)
- ✅ Ingress support with TLS/HTTPS
- ✅ **Health probes on port 9000** (management interface)
- ✅ **Prometheus metrics** with pod annotations
- ✅ Resource management and autoscaling
- ✅ **NetworkPolicy support** (optional)
- ✅ **ConfigMap for custom themes/realms**
- ✅ Security best practices (non-root, no privilege escalation)
- ✅ Environment-specific configurations (dev, staging, production)
- ✅ **GitOps ready** (Argo CD, Flux CD)
- ✅ **Comprehensive inline comments** in all templates

## Repository Structure

```text
keycloak-ops/
├── helm/
│   └── keycloak/              # Helm chart
│       ├── Chart.yaml
│       ├── values.yaml
│       ├── templates/
│       └── README.md
├── kustomize/
│   ├── base/                  # Base manifests
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   ├── ingress.yaml
│   │   ├── postgres.yaml
│   │   └── kustomization.yaml
│   └── overlays/             # Environment overlays
│       ├── dev/
│       ├── staging/
│       └── production/
├── local/                     # Local development with Kind
│   ├── kind-config.yaml
│   └── README.md
└── docs/
    ├── HELM_DEPLOYMENT.md
    └── KUSTOMIZE_DEPLOYMENT.md
```

## Quick Start

### Option 1: Deploy with Kustomize (Recommended for Quick Testing)

Kustomize includes everything (Keycloak + PostgreSQL) in one command:

```bash
# Deploy using Kustomize base (includes Keycloak + PostgreSQL)
kubectl apply -k kustomize/base/

# Watch pods starting
kubectl get pods -n keycloak -w
# Wait until both keycloak and postgres pods show: 1/1 Running

# Access Keycloak (port-forward for testing)
kubectl port-forward -n keycloak svc/keycloak 8080:8080
```

**Default credentials:**
- Username: `admin`
- Password: `admin123`

Access Keycloak at: <http://localhost:8080>

**Environment overlays:** For dev/staging/production environments, use:
```bash
kubectl apply -k kustomize/overlays/dev        # Development
kubectl apply -k kustomize/overlays/staging    # Staging
kubectl apply -k kustomize/overlays/production # Production
```

### Option 2: Deploy with Helm

**⚠️ Important:** The Helm chart does NOT include PostgreSQL. You must deploy it separately.

```bash
# Step 1: Create namespace
kubectl create namespace keycloak

# Step 2: Deploy PostgreSQL first
kubectl apply -f kustomize/base/postgres.yaml

# Step 3: Wait for PostgreSQL to be ready
kubectl wait --for=condition=ready pod -l app=postgres -n keycloak --timeout=300s

# Step 4: Install Keycloak with Helm
# ⚠️ CRITICAL: database password MUST match postgres password (keycloak123)
helm install keycloak ./helm/keycloak \
  --namespace keycloak \
  --set keycloak.admin.password=admin123 \
  --set keycloak.database.password=keycloak123

# Step 5: Watch deployment
kubectl get pods -n keycloak -w
# Wait until keycloak pods show: 1/1 Running

# Step 6: Access Keycloak (port-forward for testing)
kubectl port-forward -n keycloak svc/keycloak 8080:8080
```

**Default credentials:**
- Username: `admin`  
- Password: `admin123` (or the password you set)

Access Keycloak at: <http://localhost:8080>

> **Note:** For production deployments with external databases, see the [Helm Deployment Guide](docs/HELM_DEPLOYMENT.md).

## Local Development (Kind)

For local development and testing with Kind (Kubernetes in Docker), see the [local/](local/) directory.

### Method 1: Kustomize (Simplest)
```bash
# Create Kind cluster
kind create cluster --name keycloak-demo --config local/kind-config.yaml
# Deploy using Kustomize base (includes Keycloak + PostgreSQL)
kubectl apply -k kustomize/base/

# Watch pods starting
kubectl get pods -n keycloak -w

# Wait until both pods show: 1/1 Running

# Port forward to access
kubectl port-forward -n keycloak svc/keycloak 8080:8080
# Access: http://localhost:8080 (admin/admin123)
```
Access: <http://localhost:8080> (admin/admin123)
### Method 2: Helm
```bash
# Create Kind cluster
kind create cluster --name keycloak-demo --config local/kind-config.yaml
# Step 1: Deploy PostgreSQL first
kubectl create namespace keycloak

kubectl apply -f kustomize/base/postgres.yaml

# Deploy keycloak via Helm
helm install keycloak ./helm/keycloak --namespace keycloak \
  --create-namespace \
  --set ingress.enabled=false \
  --set keycloak.admin.password=admin123 \
  --set keycloak.database.password=keycloak123
```

## Documentation

### Detailed Guides

- 📖 [**Helm Deployment Guide**](docs/HELM_DEPLOYMENT.md) - Complete Helm deployment instructions
- 📖 [**Kustomize Deployment Guide**](docs/KUSTOMIZE_DEPLOYMENT.md) - Kustomize deployment with overlays

### Key Topics

#### Helm Chart

- Custom values configuration
- External database setup
- High availability configuration
- Autoscaling setup
- TLS/HTTPS configuration
- Production checklist

#### Kustomize

- Environment-specific overlays
- Secret management
- Resource customization
- GitOps integration (ArgoCD, Flux)
- Rollback strategies

## Configuration Examples

### Helm: Production Deployment

Create `values-prod.yaml`:

```yaml
replicaCount: 3

keycloak:
  admin:
    password: "SecureAdminPassword"
  database:
    host: postgres.production.svc.cluster.local
    password: "SecureDbPassword"

ingress:
  enabled: true
  className: nginx
  hosts:
    - host: keycloak.yourdomain.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: keycloak-tls
      hosts:
        - keycloak.yourdomain.com

resources:
  limits:
    cpu: 4000m
    memory: 4Gi
  requests:
    cpu: 1000m
    memory: 2Gi

autoscaling:
  enabled: true
  minReplicas: 3
  maxReplicas: 10
```

Deploy:

```bash
helm install keycloak ./helm/keycloak \
  --namespace keycloak \
  --values values-prod.yaml
```

### Kustomize: Production Overlay

The production overlay automatically configures:

- 3 replicas
- Enhanced resources (1000m CPU, 2Gi RAM)
- Production hostname
- TLS with Let's Encrypt

Deploy:

```bash
kubectl apply -k kustomize/overlays/production
```

## Environment Configurations

### Development

- **Namespace**: keycloak-dev
- **Replicas**: 1
- **Resources**: Standard
- **Hostname**: keycloak-dev.example.com

### Staging

- **Namespace**: keycloak-staging
- **Replicas**: 2
- **Resources**: Standard
- **Hostname**: keycloak-staging.example.com
- **TLS**: Let's Encrypt Staging

### Production

- **Namespace**: keycloak-prod
- **Replicas**: 3
- **Resources**: Enhanced (1000m CPU, 2Gi RAM)
- **Hostname**: keycloak.example.com
- **TLS**: Let's Encrypt Production

## Verification

### Check Deployment Status

```bash
# Check pods
kubectl get pods -n keycloak

# Check services
kubectl get svc -n keycloak

# Check ingress
kubectl get ingress -n keycloak

# View logs
kubectl logs -n keycloak -l app.kubernetes.io/name=keycloak
```

### Access Admin Console

#### Get Admin Credentials (Helm)

```bash
# Get admin password
kubectl get secret keycloak -n keycloak \
  -o jsonpath="{.data.admin-password}" | base64 --decode
```

#### Get Admin Credentials (Kustomize)

```bash
# Get username
kubectl get secret keycloak-admin -n keycloak \
  -o jsonpath="{.data.username}" | base64 --decode

# Get password
kubectl get secret keycloak-admin -n keycloak \
  -o jsonpath="{.data.password}" | base64 --decode
```

## Common Operations

### Upgrade Deployment

**Helm:**

```bash
helm upgrade keycloak ./helm/keycloak \
  --namespace keycloak \
  --values values-custom.yaml
```

**Kustomize:**

```bash
kubectl apply -k kustomize/overlays/production
```

### Scale Deployment

```bash
kubectl scale deployment keycloak \
  --replicas=5 \
  --namespace keycloak
```

### Rollback

**Helm:**
```bash
helm rollback keycloak --namespace keycloak
```

**Kustomize:**
```bash
kubectl rollout undo deployment/keycloak -n keycloak
```

### View Logs

```bash
kubectl logs -n keycloak -l app.kubernetes.io/name=keycloak --tail=100 -f
```

## Troubleshooting

### Pods Not Starting

```bash
kubectl describe pod <pod-name> -n keycloak
kubectl logs <pod-name> -n keycloak
```

### Database Connection Issues

```bash
# Test from Keycloak pod
kubectl exec -it <keycloak-pod> -n keycloak -- \
  curl -v telnet://postgres-service:5432
```

### Ingress Not Working

```bash
kubectl describe ingress keycloak -n keycloak
kubectl get events -n keycloak --sort-by='.lastTimestamp'
```

## Production Checklist

- [ ] Use external managed database (e.g., AWS RDS, GCP Cloud SQL)
- [ ] Configure secrets properly (use external secret management)
- [ ] Enable TLS/HTTPS with valid certificates
- [ ] Set appropriate resource limits and requests
- [ ] Enable autoscaling for high availability
- [ ] Configure monitoring and alerting
- [ ] Set up database backups
- [ ] Implement network policies
- [ ] Configure RBAC appropriately
- [ ] Set up log aggregation
- [ ] Document disaster recovery procedures
- [ ] Perform load testing

## Security Considerations

1. **Secrets Management**: Never commit passwords to Git. Use Kubernetes Secrets or external secret managers.
2. **TLS/HTTPS**: Always use TLS in production with valid certificates.
3. **Network Policies**: Restrict network access between components.
4. **RBAC**: Implement least-privilege access controls.
5. **Regular Updates**: Keep Keycloak and dependencies updated.
6. **Database Security**: Use encrypted connections and strong passwords.

## Monitoring and Observability

### Enable Metrics

Keycloak exposes metrics at `/metrics` endpoint when metrics are enabled.

### Prometheus Integration

Add pod annotations:

```yaml
podAnnotations:
  prometheus.io/scrape: "true"
  prometheus.io/port: "8080"
  prometheus.io/path: "/metrics"
```

### Health Endpoints

Keycloak 26.4.0 exposes health endpoints on the management port (9000):

- **Liveness**: `http://localhost:9000/health/live`
- **Readiness**: `http://localhost:9000/health/ready`
- **Startup**: `http://localhost:9000/health/started`
- **Metrics**: `http://localhost:8080/metrics`

## Backup and Disaster Recovery

### Database Backup

```bash
# Backup PostgreSQL
kubectl exec <postgres-pod> -n keycloak -- \
  pg_dump -U keycloak keycloak > backup.sql
```

### Database Restore

```bash
# Restore PostgreSQL
kubectl exec -i <postgres-pod> -n keycloak -- \
  psql -U keycloak keycloak < backup.sql
```

## Contributing

Contributions are welcome! Please follow these guidelines:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## Support

For issues and questions:

- Check the [documentation](docs/)
- Review [Keycloak official docs](https://www.keycloak.org/documentation)
- Open an issue in this repository

## License

This project is licensed under the Apache 2.0 License.

## Additional Resources

- [Keycloak Official Documentation](https://www.keycloak.org/documentation)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Helm Documentation](https://helm.sh/docs/)
- [Kustomize Documentation](https://kustomize.io/)
- [Keycloak Docker Image](https://quay.io/repository/keycloak/keycloak)

## Version Information

- **Keycloak Version**: 26.4.0 (Quarkus-based Keycloak.X)
- **PostgreSQL Version**: 15-alpine
- **Kubernetes Version**: 1.24+
- **Helm Chart Version**: 1.0.0

## GitOps Integration

### Argo CD

This Helm chart is fully compatible with Argo CD. Create an Application manifest:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: keycloak
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/yourusername/keycloak-ops.git
    targetRevision: main
    path: helm/keycloak
    helm:
      valueFiles:
        - values.yaml
      parameters:
        - name: keycloak.admin.password
          value: "$ARGOCD_ENV_ADMIN_PASSWORD"
        - name: keycloak.database.password
          value: "$ARGOCD_ENV_DB_PASSWORD"
  destination:
    server: https://kubernetes.default.svc
    namespace: keycloak
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```

### Flux CD

For Flux CD, create a HelmRelease:

```yaml
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: keycloak
  namespace: keycloak
spec:
  interval: 5m
  chart:
    spec:
      chart: ./helm/keycloak
      sourceRef:
        kind: GitRepository
        name: keycloak-ops
      interval: 1m
  values:
    replicaCount: 3
    keycloak:
      admin:
        password: ${KEYCLOAK_ADMIN_PASSWORD}
      database:
        password: ${KEYCLOAK_DB_PASSWORD}
```

### Kustomize with GitOps

The kustomize overlays are designed for GitOps workflows:

```yaml
# Argo CD Application using Kustomize
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: keycloak-prod
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/yourusername/keycloak-ops.git
    targetRevision: main
    path: kustomize/overlays/production
  destination:
    server: https://kubernetes.default.svc
    namespace: keycloak-prod
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```
