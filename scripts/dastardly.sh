#!/bin/bash
sudo su

# Update system
dnf -y update
dnf -y upgrade

# Install Docker
dnf install -y docker
systemctl enable docker
systemctl start docker

# Add ec2-user to docker group
usermod -aG docker ec2-user

# Pull Dastardly image
docker pull public.ecr.aws/portswigger/dastardly:latest

echo "Dastardly setup complete." >> /var/log/user-data.log
