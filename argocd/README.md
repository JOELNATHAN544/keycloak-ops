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

### a. Start the Cluster

First, bring up the local Kubernetes cluster using Vagrant. From the root of the project, run:

```bash
vagrant up
```

This will create a virtual machine, install k3s (Kubernetes), and install ArgoCD. The IP address for the cluster is defined in the `Vagrantfile` (default is `192.168.56.10`).

### b. Apply the ArgoCD Applications

Once the cluster is running, you need to tell ArgoCD about the applications it needs to manage. From the `argocd/` directory, run the apply script:

```bash
cd argocd
./apply_argocd.sh
```

This will create the `AppProject` and the three `Applications` (postgres, keycloak-dev, keycloak-prod) in ArgoCD. ArgoCD will then automatically sync them with the configurations in this Git repository.

### c. Accessing the Services

The services are exposed via `NodePort` on the cluster's IP address. The IP is configured in the `Vagrantfile` (default `192.168.56.10`), but the ports are assigned dynamically. Use the following commands to find the correct ports and construct the URLs.

- **ArgoCD UI:**
  - **Get Port:** The ArgoCD port is fixed at `30080`.
  - **URL:** `http://192.168.56.10:30080`
  - **Username:** `admin`
  - **Password:** Retrieve the auto-generated password with this command:
    ```bash
    vagrant ssh -c "kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
    ```

- **Keycloak (Development Environment):**
  - **Get Port:** Find the `NodePort` for the `keycloak-dev-helm` service:
    ```bash
    vagrant ssh -c "kubectl get svc -n keycloak-dev keycloak-dev-helm -o jsonpath='{.spec.ports[0].nodePort}'"
    ```
  - **URL:** `http://192.168.56.10:<DEV_NODE_PORT>`
  - **Admin Username:** `admin`
  - **Admin Password:** `admin123`

- **Keycloak (Production Environment):**
  - **Get Port:** Find the `NodePort` for the `keycloak-helm` service:
    ```bash
    vagrant ssh -c "kubectl get svc -n keycloak keycloak-helm -o jsonpath='{.spec.ports[0].nodePort}'"
    ```
  - **URL:** `http://192.168.56.10:<PROD_NODE_PORT>`
  - **Admin Username:** `admin`
  - **Admin Password:** `admin123`
