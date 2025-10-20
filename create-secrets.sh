#!/bin/bash
set -e

NAMESPACE=${1:-keycloak}
ADMIN_PASSWORD=${ADMIN_PASSWORD:-$(openssl rand -base64 32)}
DB_PASSWORD=${DB_PASSWORD:-$(openssl rand -base64 32)}

echo "Creating secrets in namespace: $NAMESPACE"
echo "================================================"
echo "SAVE THESE CREDENTIALS SECURELY!"
echo "Admin Username: admin"
echo "Admin Password: $ADMIN_PASSWORD"
echo "DB Username: keycloak"
echo "DB Password: $DB_PASSWORD"
echo "================================================"

# Create namespace if it doesn't exist
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# Create secrets
kubectl create secret generic keycloak-admin \
  --from-literal=username=admin \
  --from-literal=password=$ADMIN_PASSWORD \
  --namespace $NAMESPACE \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl create secret generic keycloak-db \
  --from-literal=username=keycloak \
  --from-literal=password=$DB_PASSWORD \
  --namespace $NAMESPACE \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl create secret generic postgres-secret \
  --from-literal=POSTGRES_PASSWORD=$DB_PASSWORD \
  --namespace $NAMESPACE \
  --dry-run=client -o yaml | kubectl apply -f -

echo "✅ Secrets created successfully in namespace: $NAMESPACE"