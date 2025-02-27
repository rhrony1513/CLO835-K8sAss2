#!/bin/bash
set -ex

# Update system and install Docker
sudo yum update -y
sudo yum install docker -y

# Start Docker service
sudo systemctl start docker

# Add ec2-user to docker group
sudo usermod -a -G docker ec2-user

# Apply the group change immediately for the current session
newgrp docker  # This applies the group change so ec2-user can run Docker commands without needing a logout

# Install Kind and kubectl
curl -sLo kind https://kind.sigs.k8s.io/dl/v0.11.0/kind-linux-amd64
sudo install -o root -g root -m 0755 kind /usr/local/bin/kind
rm -f ./kind

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm -f ./kubectl
