#!/bin/bash

# Update system packages
sudo yum update -y
sudo yum install -y curl coreutils

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check || { echo "Checksum verification failed"; exit 1; }
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Install Minikube
curl -LO https://github.com/kubernetes/minikube/releases/latest/download/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube && rm minikube-linux-amd64

# Start Minikube
minikube start

# Configure kubectl to use Minikube
kubectl config use-context minikube

# Verify cluster-info
output=$(kubectl cluster-info 2>&1)
status=$?

if [ $status -eq 0 ]; then
    echo "Kubernetes cluster is running:"
    echo "$output" | sudo tee /var/log/cluster-info.txt
else
    echo "Failed to retrieve cluster info. Error: $output" | sudo tee -a /var/log/cluster-info.txt
fi
