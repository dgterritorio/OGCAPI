# OGC API Kubernetes Deployment

This repository contains the Kubernetes configuration for deploying the OGC API service from DGT (Direção-Geral do Território).

## Quick Start

### Local Development with Minikube

1. **Start Minikube**
   ```bash
   minikube start --cpus=4 --memory=8192 --disk-size=20g
   
   # Enable required addons
   minikube addons enable ingress
   minikube addons enable storage-provisioner
   ```

2. **Build Docker images** (if using custom images)
   ```bash
   eval $(minikube docker-env)
   docker build -t ogcapi/postgis:local postgis/
   docker build -t ogcapi/db-init:local utils/
   ```

3. **Deploy the application**
   ```bash
   kubectl apply -k kubernetes/overlays/local/
   ```

4. **Wait for pods to be ready**
   ```bash
   kubectl wait --for=condition=ready pod --all --timeout=300s
   ```

5. **Access the application**
   ```bash
   # Get Minikube IP
   export MINIKUBE_IP=$(minikube ip)
   echo "Access the application at: http://$MINIKUBE_IP"
   ```

6. **Monitor the app**
   ```bash
   minikube dashboard
   ```

## Configuration

### Environment-specific configurations

The deployment uses Kustomize overlays for different environments:

- `kubernetes/base/` - Base configuration shared across all environments
- `kubernetes/overlays/local/` - Local development with Minikube
- `kubernetes/overlays/test/` - TODO Test environment configuration
- `kubernetes/overlays/production/` - TODO Production environment configuration

### Access logs
```bash
# View ingress access logs
kubectl logs -n ingress-nginx deployment/ingress-nginx-controller | grep ogcapi

# Follow logs in real-time
kubectl logs -f -n ingress-nginx deployment/ingress-nginx-controller
```

