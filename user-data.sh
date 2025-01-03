#!/bin/bash

# Install dependencies
sudo apt-get update
sudo apt-get install -y curl coreutils

# Download kubectl and sha256 file
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"

# Verify checksum
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check || { echo "Checksum verification failed"; exit 1; }

# Install kubectl
if ! command -v kubectl &> /dev/null; then
    echo "Installing kubectl..."
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
else
    echo "kubectl is already installed."
fi

# Install Minikube
curl -LO https://github.com/kubernetes/minikube/releases/latest/download/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube && rm minikube-linux-amd64

# Run kubectl version and log output
kubectl version --client --output=yaml | sudo tee /var/log/install-output.yaml > /dev/null

# Run kubectl cluster-info and handle errors
output=$(kubectl cluster-info 2>&1)
status=$?

if [ $status -eq 0 ]; then
    echo "kubectl cluster-info executed successfully." | sudo tee /var/log/cluster-info.txt
    echo "$output" | sudo tee -a /var/log/cluster-info.txt
else
    echo "kubectl cluster-info failed with exit code $status." | sudo tee -a /var/log/cluster-info.txt
    echo "Error: $output" >&2
fi
