# Keycloak Helm Chart

A Helm chart for deploying Keycloak on Kubernetes with PostgreSQL support.

## Features

- Production-ready Keycloak deployment
- Built-in PostgreSQL database (optional)
- High availability with multiple replicas
- Ingress support with TLS
- Health checks and startup probes
- Resource management and autoscaling
- Security best practices

## Installation

### Quick Install

```bash
helm install keycloak ./helm/keycloak \
  --namespace keycloak \
  --create-namespace \
  --set keycloak.admin.password=YourSecurePassword
```

### Install with Custom Values

```bash
helm install keycloak ./helm/keycloak \
  --namespace keycloak \
  --create-namespace \
  --values values-custom.yaml
```

## Configuration

See [values.yaml](values.yaml) for all configuration options.

### Key Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of Keycloak replicas | `2` |
| `image.repository` | Keycloak image repository | `quay.io/keycloak/keycloak` |
| `image.tag` | Keycloak image tag | `23.0.0` |
| `keycloak.admin.username` | Admin username | `admin` |
| `keycloak.admin.password` | Admin password | _Required_ |
| `keycloak.database.vendor` | Database vendor | `postgres` |
| `postgresql.enabled` | Deploy PostgreSQL | `true` |
| `ingress.enabled` | Enable ingress | `true` |
| `ingress.hosts[0].host` | Ingress hostname | `keycloak.example.com` |

## Upgrading

```bash
helm upgrade keycloak ./helm/keycloak \
  --namespace keycloak \
  --values values-custom.yaml
```

## Uninstalling

```bash
helm uninstall keycloak --namespace keycloak
```

## Documentation

For detailed deployment instructions, see:

- [Helm Deployment Guide](../../docs/HELM_DEPLOYMENT.md)
- [Official Keycloak Documentation](https://www.keycloak.org/documentation)

## Requirements

- Kubernetes 1.24+
- Helm 3.x

## License

Apache 2.0
