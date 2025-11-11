# Setting Up an ArgoCD Environment

This guide explains how to install and configure ArgoCD in your Kubernetes cluster, making it ready for use with this project.

## 1. Prerequisites

*   A running Kubernetes cluster (e.g., `k3s`, `minikube`, or a cloud provider).
*   `kubectl` installed and configured to point to your cluster.

## 2. Installing ArgoCD

Run the following commands from a shell with access to your cluster.

- **Create the Namespace:**
  ```bash
  kubectl create namespace argocd
  ```

- **Apply the Installation Manifest:**
  ```bash
  kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
  ```

## 3. Exposing Services with Ingress

To expose services like the ArgoCD UI and other applications, we will use an Ingress controller.

- **Install NGINX Ingress Controller:**
  ```bash
  kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.10.1/deploy/static/provider/cloud/deploy.yaml
  ```

- **Wait for the Controller to be Ready:**
  ```bash
  kubectl wait --namespace ingress-nginx --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=120s
  ```

## 4. Accessing the Environment

- **Get Your Cluster IP and Ingress Port:**
  You will need the IP address of one of your Kubernetes nodes and the port assigned to the Ingress controller.
  ```bash
  # Get the IP
  kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}'

  # Get the Port
  kubectl get svc ingress-nginx-controller --namespace=ingress-nginx -o jsonpath='{.spec.ports[0].nodePort}'
  ```

- **Accessing Services via Ingress:**
  To access services like the ArgoCD UI, you must create an `Ingress` resource for them. This typically involves defining a path that maps to the service in the cluster.

  For example, to expose the ArgoCD server, you would create an Ingress that routes a path like `/argocd` to the `argocd-server` service on port 80.

  - **Example URL:** `http://<YOUR_CLUSTER_IP>:<INGRESS_PORT>/<your-path>`
  - **Username:** `admin`
  - **Password:** Retrieve the initial admin password with this command:
    ```bash
    kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d
    ```

## 5. Deploying an Application

This project is now ready for GitOps. To deploy a new application:

1.  Add your ArgoCD `Application` manifest to the `argocd/` directory.
2.  If external access is needed, create an `Ingress` resource pointing to your application's service.
3.  Apply the manifests to your cluster. ArgoCD will then manage the deployment.
