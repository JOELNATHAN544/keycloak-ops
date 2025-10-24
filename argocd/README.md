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
