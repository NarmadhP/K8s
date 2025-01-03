## user data script for aws instance which installs k8s tools such as kubectl 

#!/bin/bash
echo "installing necessary tools"
 sudo apt-get update
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"

echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check

echo "installing kubectl"

sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

kubectl version --client --output=yaml > install-ouput.yaml

#kubectl cluster-info > cluster-info.txt
# Run the version command and redirect output to a file

kubectl version --client --output=yaml > /var/log/install-output.yaml

#we are cataching standard output and standard error to output var
# $? aptures exit status of the command
output=$(kubectl cluster-info 2>&1)
status=$?

if [ $status -eq 0 ]; then 
  echo "output:" /var/log/cluster-info.txt 
else 
  echo "Error occurred: $output" >&2
fi 
