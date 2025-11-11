# ArgoCD Application Manifests

This directory is intended to hold the ArgoCD `Application` and `AppProject` manifests for deploying applications onto the Kubernetes cluster.

## Purpose

By defining applications as code here, we can use ArgoCD to automate deployments and ensure the cluster state always matches the configuration in this Git repository.

## Getting Started

To deploy a new application:

1.  Create a new YAML file in this directory (e.g., `my-app.yaml`).
2.  Define an ArgoCD `Application` resource in the file, pointing to the source of your application's manifests (e.g., another Git repository, a Helm chart).
3.  Commit the file to this repository.
4.  Apply the manifest to the cluster:
    ```bash
    kubectl apply -f my-app.yaml
    ```

ArgoCD will then take over and manage the deployment.

## Setting Up an ArgoCD Environment

This guide explains how to install and configure ArgoCD in your Kubernetes cluster, making it ready for use with this project.

### 1. Prerequisites

*   A running Kubernetes cluster (e.g., `k3s`, `minikube`, or a cloud provider).
*   `kubectl` installed and configured to point to your cluster.

### 2. Installing ArgoCD

Run the following commands from a shell with access to your cluster.

- **Create the Namespace:**
  ```bash
  kubectl create namespace argocd
  ```

- **Apply the Installation Manifest:**
  ```bash
  kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
  ```

### 3. Exposing Services with Ingress

Services are exposed via an Ingress controller for centralized access.

- **Install NGINX Ingress Controller:**
  ```bash
  kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.10.1/deploy/static/provider/cloud/deploy.yaml
  ```

### 4. Accessing the Environment

- **Get Cluster IP and Ingress Port:**
  ```bash
  # Get the IP
  kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}'

  # Get the Port
  kubectl get svc ingress-nginx-controller --namespace=ingress-nginx -o jsonpath='{.spec.ports[0].nodePort}'
  ```

- **Accessing Services:**
  Once the Ingress controller is running, you can create `Ingress` resources to expose your applications. Access them at `http://<YOUR_CLUSTER_IP>:<INGRESS_PORT>/<your-path>`.
  - **Username:** `admin`
  - **Password:** Retrieve the initial admin password with this command:
    ```bash
    kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d
    ```

### 5. Deploying an Application

To deploy an application:

1.  Add the ArgoCD `Application` manifest to this directory.
2.  If needed, add an `Ingress` manifest to expose the application's service.
3.  Apply the manifest(s) to the cluster.
