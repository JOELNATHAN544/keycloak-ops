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

### 3. Exposing the ArgoCD UI

By default, the ArgoCD UI is not exposed externally. To access it via a `NodePort`, patch the `argocd-server` service.

- **Patch the Service:**
  ```bash
  kubectl patch svc argocd-server -n argocd -p '{"spec":{"type":"NodePort","ports":[{"port":80,"targetPort":8080,"nodePort":30080},{"port":443,"targetPort":8080,"nodePort":30443}]}}'
  ```

### 4. Accessing the Environment

- **Get Your Cluster IP:**
  You will need the IP address of one of your Kubernetes nodes. For local clusters, you can often find this with `minikube ip` or by checking your VM's network configuration.

- **Access the ArgoCD UI:**
  - **URL:** `http://<YOUR_CLUSTER_IP>:30080`
  - **Username:** `admin`
  - **Password:** Retrieve the initial admin password with this command:
    ```bash
    kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d
    ```

### 5. Deploying an Application (Example)

This project structure is now ready for a GitOps demonstration. To deploy an application:

1.  Create a new application manifest in the `argocd/` directory (e.g., `guestbook.yaml`).
2.  Apply the manifest from your shell:
    ```bash
    kubectl apply -f argocd/guestbook.yaml
    ```

ArgoCD will detect the new application and deploy it to the cluster.
