# ArgoCD GitOps for Keycloak

This document outlines the GitOps-based deployment strategy for the Keycloak application, managed by ArgoCD. This setup was created to resolve GitHub Issue #2: "Setup argocd project for keycloak helm chart".

## 1. Core Concept

The primary goal of this project is to use **GitOps** principles to automate the deployment and management of Keycloak in a multi-environment Kubernetes cluster.

- **Git as the Single Source of Truth:** The configuration for our infrastructure and applications resides entirely within this Git repository. Any changes to the system (e.g., updating Keycloak version, changing configuration) are made by pushing commits to this repository.
- **Automated Synchronization:** ArgoCD runs inside the Kubernetes cluster, continuously monitoring the Git repository. When it detects a difference between the configuration in Git and the live state in the cluster, it automatically applies the necessary changes to bring the cluster into the desired state.
- **Multi-Environment Deployment:** We have established two distinct environments:
    - **Development (`develop` branch):** This environment is automatically updated with every push to the `develop` branch, providing a space for testing the latest changes.
    - **Production (`v1.0.0` tag):** This environment is locked to a specific Git tag (`v1.0.0`). It is only updated when this tag is deliberately moved to a new, stable commit, ensuring the stability of the production system.

## 2. Directory Structure

All ArgoCD-related configurations are located within this `argocd/` directory.

- `project-keycloak.yaml`: Defines an ArgoCD `AppProject`, which is a logical grouping for our applications. It specifies which Git repositories are trusted and which Kubernetes namespaces the applications are allowed to deploy to.
- `app-postgres.yaml`: An ArgoCD `Application` manifest that manages the deployment of our shared PostgreSQL database into the `keycloak` namespace.
- `app-keycloak-dev.yaml`: The `Application` manifest for the **development** Keycloak instance. It points to the `develop` branch of our Git repository.
- `app-keycloak-prod.yaml`: The `Application` manifest for the **production** Keycloak instance. It points to the `v1.0.0` tag of our Git repository.
- `postgres/`: This directory contains the raw Kubernetes manifests for deploying PostgreSQL, including its `Deployment`, `Service`, and the `NetworkPolicy` required for Keycloak to connect to it.
- `.env`: A configuration file that holds environment-specific variables (like the Git repository URL and branch/tag names) used by the `apply_argocd.sh` script.
- `apply_argocd.sh`: A helper script that applies all our ArgoCD `Application` and `AppProject` manifests to the Kubernetes cluster.

## 3. Initial Setup and Testing

Follow these steps to bring up the environment and access the services.

### a. Prepare Your Kubernetes Cluster

This project requires a running Kubernetes cluster with ArgoCD installed. The setup is environment-agnostic and can be run in any cluster (e.g., local `k3s`, `minikube`, or a cloud provider).

Ensure your `kubectl` is configured to point to the correct cluster where you intend to deploy Keycloak.

### b. Apply the ArgoCD Applications

Once your cluster is ready, you need to apply the ArgoCD application manifests. **Log into a shell environment that has access to your cluster**, navigate to the `argocd/` directory, and run the apply script:

```bash
# Example for Vagrant users:
# vagrant ssh -c "cd /vagrant/argocd && ./apply_argocd.sh"

# For other environments, get a shell inside your cluster and run:
cd argocd
./apply_argocd.sh
```

This will create the `AppProject` and the three `Applications` (postgres, keycloak-dev, keycloak-prod) in ArgoCD. ArgoCD will then automatically sync them with the configurations in this Git repository.

### c. Accessing the Services

The services are exposed via `NodePort`. To access them, you will need the IP address of your Kubernetes node and the dynamically assigned port for each service.

- **ArgoCD UI:**
  - **Get Port:** The ArgoCD `NodePort` is fixed at **`30080`**.
  - **URL:** `http://<YOUR_CLUSTER_IP>:30080`
  - **Username:** `admin`
  - **Password:** Retrieve the auto-generated password with this command (run from a shell with cluster access):
    ```bash
    kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d
    ```

- **Keycloak (Development Environment):**
  - **Get Port:** Find the `NodePort` for the `keycloak-dev-helm` service:
    ```bash
    kubectl get svc -n keycloak-dev keycloak-dev-helm -o jsonpath='{.spec.ports[0].nodePort}'
    ```
  - **URL:** `http://<YOUR_CLUSTER_IP>:<DEV_NODE_PORT>`
  - **Admin Username:** `admin`
  - **Admin Password:** `admin123`

- **Keycloak (Production Environment):**
  - **Get Port:** Find the `NodePort` for the `keycloak-helm` service:
    ```bash
    kubectl get svc -n keycloak keycloak-helm -o jsonpath='{.spec.ports[0].nodePort}'
    ```
  - **URL:** `http://<YOUR_CLUSTER_IP>:<PROD_NODE_PORT>`
  - **Admin Username:** `admin`
  - **Admin Password:** `admin123`
