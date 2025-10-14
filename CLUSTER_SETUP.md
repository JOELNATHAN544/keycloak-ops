# Keycloak Cluster Setup Guide

This guide helps you set up a local Kubernetes cluster using Vagrant for testing ArgoCD with Keycloak deployments.

## Prerequisites

Before starting, ensure you have the following installed:

- [Vagrant](https://www.vagrantup.com/downloads) (>= 2.3.0)
- [VirtualBox](https://www.virtualbox.org/wiki/Downloads) (>= 6.1)
- At least 6GB of free RAM
- At least 15GB of free disk space

## Quick Start

1. **Start the cluster:**
   ```bash
   ./cluster-setup.sh start
   ```

2. **Check cluster status:**
   ```bash
   ./cluster-setup.sh status
   ```

3. **Access ArgoCD UI:**
   - URL: http://localhost:30080
   - Username: `admin`
   - Password: Check `argocd-password.txt` file

## Cluster Specifications

- **OS:** Ubuntu 22.04 LTS
- **Kubernetes:** k3s (lightweight distribution)
- **Resources:** 4GB RAM, 2 CPU cores
- **Storage:** 10GB additional disk for containers
- **Network:** 192.168.56.10 (private network)

## Port Forwarding

The following ports are forwarded from the VM to your host:

| Service | VM Port | Host Port | Description |
|---------|---------|-----------|-------------|
| HTTP | 80 | 8080 | General HTTP traffic |
| HTTPS | 443 | 8443 | General HTTPS traffic |
| Kubernetes API | 6443 | 6443 | kubectl access |
| ArgoCD UI | 30080 | 30080 | ArgoCD web interface |
| ArgoCD HTTPS | 30443 | 30443 | ArgoCD secure access |

## Using kubectl

After the cluster is running, you can use kubectl from your host machine:

```bash
# Set the kubeconfig
export KUBECONFIG=./kubeconfig

# Check cluster status
kubectl get nodes
kubectl get pods --all-namespaces

# Check ArgoCD
kubectl get pods -n argocd
```

## ArgoCD Access

### Web UI Access
- URL: http://localhost:30080
- Username: `admin`
- Password: Found in `argocd-password.txt`

### CLI Access
```bash
# Install ArgoCD CLI (optional)
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd

# Login via CLI
argocd login localhost:30080 --username admin --password $(cat argocd-password.txt) --insecure
```

## Deploying Applications

1. **Update repository URLs** in your ArgoCD application manifests:
   ```yaml
   spec:
     source:
       repoURL: https://github.com/yourusername/your-keycloak-repo
   ```

2. **Deploy applications:**
   ```bash
   ./cluster-setup.sh deploy
   ```

## Cluster Management Commands

```bash
# Start cluster
./cluster-setup.sh start

# Stop cluster (preserves data)
./cluster-setup.sh stop

# Check status
./cluster-setup.sh status

# SSH into cluster
./cluster-setup.sh ssh

# Deploy ArgoCD applications
./cluster-setup.sh deploy

# Destroy cluster (removes all data)
./cluster-setup.sh destroy
```

## Troubleshooting

### Cluster Won't Start
1. Check VirtualBox is running: `VBoxManage list runningvms`
2. Ensure sufficient resources are available
3. Check Vagrant logs: `vagrant up --debug`

### kubectl Connection Issues
1. Verify kubeconfig file exists: `ls -la kubeconfig`
2. Check cluster IP is accessible: `ping 192.168.56.10`
3. Restart the cluster: `./cluster-setup.sh stop && ./cluster-setup.sh start`

### ArgoCD Not Accessible
1. Check ArgoCD pods: `kubectl get pods -n argocd`
2. Verify service: `kubectl get svc -n argocd`
3. Check port forwarding in Vagrant

### Performance Issues
- Increase VM memory in `Vagrantfile` (currently 4GB)
- Reduce resource requests in Keycloak manifests
- Use fewer replicas for development

## Development Workflow

1. **Make changes** to your ArgoCD applications or Helm charts
2. **Commit and push** to your Git repository
3. **Sync applications** in ArgoCD UI or use CLI:
   ```bash
   argocd app sync keycloak-dev
   ```
4. **Monitor deployment** in ArgoCD UI or kubectl:
   ```bash
   kubectl get pods -n keycloak-dev
   ```

## Security Notes

- This setup is for **development only**
- ArgoCD uses insecure connections (HTTP)
- Default passwords should be changed in production
- VM has full network access - use firewall if needed

## Cleanup

To completely remove the cluster and free up disk space:

```bash
./cluster-setup.sh destroy
```

This will:
- Destroy the Vagrant VM
- Remove the virtual disk file
- Clean up kubeconfig and password files
