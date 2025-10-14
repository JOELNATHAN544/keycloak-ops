#!/bin/bash

# Keycloak Cluster Setup Script
# This script helps you manage your Vagrant-based Kubernetes cluster

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KUBECONFIG_FILE="$SCRIPT_DIR/kubeconfig"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_prerequisites() {
    print_status "Checking prerequisites..."
    
    if ! command -v vagrant &> /dev/null; then
        print_error "Vagrant is not installed. Please install Vagrant first."
        exit 1
    fi
    
    if ! command -v VBoxManage &> /dev/null; then
        print_error "VirtualBox is not installed. Please install VirtualBox first."
        exit 1
    fi
    
    print_success "Prerequisites check passed"
}

start_cluster() {
    print_status "Starting Keycloak cluster..."
    
    cd "$SCRIPT_DIR"
    vagrant up
    
    if [ -f "$KUBECONFIG_FILE" ]; then
        print_success "Cluster started successfully!"
        print_status "Kubeconfig available at: $KUBECONFIG_FILE"
        
        if [ -f "argocd-password.txt" ]; then
            ARGOCD_PASSWORD=$(cat argocd-password.txt)
            print_success "ArgoCD is available at: http://localhost:30080"
            print_status "Username: admin"
            print_status "Password: $ARGOCD_PASSWORD"
        fi
    else
        print_error "Cluster setup may have failed. Check vagrant logs."
        exit 1
    fi
}

stop_cluster() {
    print_status "Stopping Keycloak cluster..."
    cd "$SCRIPT_DIR"
    vagrant halt
    print_success "Cluster stopped"
}

destroy_cluster() {
    print_warning "This will completely destroy the cluster and all data!"
    read -p "Are you sure? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        cd "$SCRIPT_DIR"
        vagrant destroy -f
        rm -f kubeconfig argocd-password.txt cluster-disk.vdi
        print_success "Cluster destroyed"
    else
        print_status "Operation cancelled"
    fi
}

status_cluster() {
    print_status "Checking cluster status..."
    cd "$SCRIPT_DIR"
    vagrant status
    
    if [ -f "$KUBECONFIG_FILE" ]; then
        print_status "Testing cluster connectivity..."
        export KUBECONFIG="$KUBECONFIG_FILE"
        
        if kubectl get nodes &> /dev/null; then
            print_success "Cluster is accessible"
            kubectl get nodes
            echo
            print_status "ArgoCD status:"
            kubectl get pods -n argocd
        else
            print_warning "Cluster is running but not accessible via kubectl"
        fi
    fi
}

ssh_cluster() {
    print_status "Connecting to cluster via SSH..."
    cd "$SCRIPT_DIR"
    vagrant ssh
}

deploy_argocd_apps() {
    print_status "Deploying ArgoCD applications..."
    
    if [ ! -f "$KUBECONFIG_FILE" ]; then
        print_error "Cluster is not running. Start it first with: $0 start"
        exit 1
    fi
    
    export KUBECONFIG="$KUBECONFIG_FILE"
    
    # Apply ArgoCD project
    if [ -f "argocd/projects/keycloak-project.yaml" ]; then
        print_status "Applying ArgoCD project..."
        kubectl apply -f argocd/projects/keycloak-project.yaml
    fi
    
    # Apply applications (you'll need to customize these with your repo URL)
    print_warning "Before applying applications, make sure to update the repoURL in your YAML files"
    print_status "Available applications:"
    ls -la argocd/base/*.yaml
    
    read -p "Do you want to apply the applications now? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        for app in argocd/base/*.yaml; do
            print_status "Applying $(basename "$app")..."
            kubectl apply -f "$app"
        done
        print_success "Applications deployed to ArgoCD"
    fi
}

show_help() {
    echo "Keycloak Cluster Management Script"
    echo
    echo "Usage: $0 [COMMAND]"
    echo
    echo "Commands:"
    echo "  start     Start the Vagrant cluster"
    echo "  stop      Stop the Vagrant cluster"
    echo "  destroy   Destroy the cluster completely"
    echo "  status    Show cluster status"
    echo "  ssh       SSH into the cluster"
    echo "  deploy    Deploy ArgoCD applications"
    echo "  help      Show this help message"
    echo
    echo "Examples:"
    echo "  $0 start                 # Start the cluster"
    echo "  $0 status                # Check cluster status"
    echo "  $0 deploy                # Deploy ArgoCD apps"
    echo
}

# Main script logic
case "${1:-help}" in
    "start")
        check_prerequisites
        start_cluster
        ;;
    "stop")
        stop_cluster
        ;;
    "destroy")
        destroy_cluster
        ;;
    "status")
        status_cluster
        ;;
    "ssh")
        ssh_cluster
        ;;
    "deploy")
        deploy_argocd_apps
        ;;
    "help"|*)
        show_help
        ;;
esac
