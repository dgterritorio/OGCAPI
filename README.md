# OGC API Kubernetes Deployment

This repository contains the Kubernetes configuration for deploying the OGC API service from DGT (Direção-Geral do Território).

## Quick Start

### Local Development with Minikube

## Prerequisites
1. Install Minikube
2. Install kubectl

## Setup Instructions

_minikube_ is a docker container running with inside a complete kubernetes ecosystem. It's easy, but that mean you have to use this container as your host machine. For example if you need to use images, you have to build them inside the container. Or if you need made files available, you need to copy them inside the container. Of course there are dedicated minikube commands to do so.
Some commands are with `kubectl`, the same client that you would use for the real kubernetes. 

1. Start Minikube:
```bash
minikube start --cpus=4 --memory=8192 --disk-size=20g
```

2. Enable necessary addons:
```bash
minikube addons enable ingress
minikube addons enable storage-provisioner
```
`ingress` act as web server. `storage-provisioner` creates storage when there is a volumeclaim requesting it.

3. Copy custom files to mount as volumes
```bash
kubectl create configmap pygeoapi-config   --from-file=docker.config.yml=pygeoapi/docker.config.yml
minikube mount ./data:/data &
```

3. Build custom Docker images in Minikube:
```bash
eval $(minikube docker-env)
# Build utils image
minikube image build -t ogcapi/db-init:local ./utils/
```

4. Deploy the application:
```bash
kubectl apply -k kubernetes/overlays/local/
```

5. Access the services:
```bash
# Get Minikube IP
minikube ip
```

## Monitoring
```bash
# Watch pods
kubectl get pods -w

# Check logs
kubectl logs -f deployment/pygeoapi

# Access Minikube dashboard
minikube dashboard
```