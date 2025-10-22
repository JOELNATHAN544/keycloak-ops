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

## 3. How to Test the Setup

The entire environment is running and fully functional. You can access the different components using the following URLs:

- **ArgoCD UI:**
  - **URL:** `http://192.168.56.10:30080`
  - **Username:** `admin`
  - **Password:** The password is automatically generated when the Vagrant VM is created. You can retrieve the current password by running `vagrant ssh -c "kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"` from the project root.

- **Keycloak (Development Environment):**
  - **URL:** `http://192.168.56.10:30569`
  - **Admin Username:** `admin`
  - **Admin Password:** `admin123`

- **Keycloak (Production Environment):**
  - **URL:** `http://192.168.56.10:32525`
  - **Admin Username:** `admin`
  - **Admin Password:** `admin123`
