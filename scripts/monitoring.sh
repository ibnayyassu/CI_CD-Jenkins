#!/bin/bash
sudo su

dnf -y update
dnf -y upgrade
dnf install -y docker
systemctl enable docker
systemctl start docker
usermod -aG docker ec2-user  # Added
docker run -d -p 9090:9090 prom/prometheus
docker run -d -p 3000:3000 grafana/grafana
echo "Grafana: http://<ip>:3000 (admin/admin)" >> /var/log/user-data.log
echo "Prometheus: http://<ip>:9090" >> /var/log/user-data.log
echo "Monitoring setup complete." >> /var/log/user-data.log
