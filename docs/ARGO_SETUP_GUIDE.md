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

## 3. Exposing the ArgoCD UI with Ingress

This section explains how to expose the ArgoCD UI securely using an NGINX Ingress controller with host-based routing. This is the most stable method for production-like environments.

### Step 1: Install NGINX Ingress Controller

If you haven't already, deploy the Ingress controller to your cluster.

```bash
# This command deploys the necessary resources for the NGINX Ingress controller.
kubecl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.10.1/deploy/static/provider/cloud/deploy.yaml
```

Wait for the controller to be ready:
```bash
# This command pauses until the Ingress controller pod is up and running.
kubectl wait --namespace ingress-nginx --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=120s
```

### Step 2: Generate a TLS Certificate

For HTTPS, we need a TLS certificate. The following commands create a self-signed certificate for local testing.

```bash
# 1. Generate a private key and a self-signed certificate for the hostname 'argocd.local'.
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /tmp/tls.key -out /tmp/tls.crt -subj "/CN=argocd.local"

# 2. Create a Kubernetes secret to store the key and certificate.
# The Ingress controller will use this secret to terminate TLS.
kubectl create secret tls argocd-tls --key /tmp/tls.key --cert /tmp/tls.crt -n argocd
```

### Step 3: Apply the Ingress Manifest

This project includes a pre-configured Ingress manifest to expose the ArgoCD server.

```bash
# This command applies the Ingress rule defined in the YAML file.
# It configures the Ingress controller to route traffic for 'argocd.local' to the ArgoCD server.
kubectl apply -f ../argocd/argocd-server-ingress.yaml
```

## 4. Accessing the UI

### Step 1: Configure Your Local 'hosts' File

You must tell your local computer how to resolve the `argocd.local` hostname. Add the following line to your `hosts` file:

- **On Linux/macOS:** `/etc/hosts`
- **On Windows:** `C:\Windows\System32\drivers\etc\hosts`

```
# Replace <YOUR_CLUSTER_IP> with the private IP of your Vagrant VM (e.g., 192.168.56.10).
<YOUR_CLUSTER_IP>    argocd.local
```

### Step 2: Get the HTTPS Port

The Ingress controller listens for HTTPS traffic on a specific `NodePort`. Find it with this command:

```bash
# This command retrieves the port assigned for HTTPS traffic (port 443).
kubectl get svc ingress-nginx-controller -n ingress-nginx -o jsonpath='{.spec.ports[1].nodePort}'
```

### Step 3: Open in Browser

You can now access the ArgoCD UI. Your browser will show a security warning because the certificate is self-signed; you can safely bypass it.

- **URL:** `https://argocd.local:<HTTPS_NODE_PORT>`
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
