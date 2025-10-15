#!/bin/bash

# --- Configuration ---
ENV_FILE=".env"
APPLICATIONS=("app-prod.yaml" "app-dev.yaml")

# Check for the required 'envsubst' utility
if ! command -v envsubst &> /dev/null
then
    echo "Error: 'envsubst' utility not found."
    echo "Please install it (e.g., 'sudo apt install gettext-base' or 'brew install gettext')."
    exit 1
fi

# Check if the .env file exists
if [ ! -f "$ENV_FILE" ]; then
    echo "Error: .env file not found. Please create it first."
    exit 1
fi

echo "--- Loading variables from $ENV_FILE ---"

# Load variables from .env file into the current shell environment
# This script uses 'export' to make the variables available for envsubst
export $(grep -v '^#' "$ENV_FILE" | xargs)

echo "--- Applying ArgoCD Applications via kubectl ---"

for APP_FILE in "${APPLICATIONS[@]}"; do
    if [ ! -f "$APP_FILE" ]; then
        echo "Warning: Application file $APP_FILE not found. Skipping."
        continue
    fi

    echo "Processing $APP_FILE..."
    
    # 1. Substitute variables in the YAML file using envsubst
    # 2. Pipe the resulting, fully rendered YAML to kubectl apply
    envsubst < "$APP_FILE" | kubectl apply -f -
    
    if [ $? -eq 0 ]; then
        echo "Successfully applied $APP_FILE."
    else
        echo "Error applying $APP_FILE."
    fi
    echo ""
done

echo "--- ArgoCD Sync Status ---"
echo "You can now check the ArgoCD UI or run:"
echo "kubectl get applications -n argocd"
