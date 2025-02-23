#!/bin/bash
sudo su

# Update system
dnf -y update
dnf -y upgrade

# Install Jenkins
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
dnf install -y java-17-amazon-corretto-devel
dnf install -y jenkins-2.479.3-1.1.noarch

# Start Jenkins
systemctl enable jenkins
systemctl start jenkins

# Install Nginx for health check
dnf install -y nginx
mkdir -p /var/www/healthcheck
echo "<html><body>Healthy</body></html>" > /var/www/healthcheck/index.html
cat <<EOT > /etc/nginx/conf.d/healthcheck.conf
server {
    listen 8081;
    location / {
        root /var/www/healthcheck;
        index index.html;
    }
}
EOT
systemctl enable nginx
systemctl start nginx

# Install utilities (Git already included)
dnf install -y git unzip curl wget

# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
unzip /tmp/awscliv2.zip -d /tmp
/tmp/aws/install
rm -rf /tmp/awscliv2.zip /tmp/aws

# Install Terraform
curl -fsSL https://releases.hashicorp.com/terraform/1.5.7/terraform_1.5.7_linux_amd64.zip -o ~/terraform.zip
unzip ~/terraform.zip -d /usr/local/bin
rm ~/terraform.zip

# Install SonarScanner
curl -fsSL https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-5.0.1.3006-linux.zip -o /tmp/sonar-scanner.zip
unzip /tmp/sonar-scanner.zip -d /opt/
mv /opt/sonar-scanner-* /opt/sonar-scanner
ln -s /opt/sonar-scanner/bin/sonar-scanner /usr/local/bin/sonar-scanner
rm /tmp/sonar-scanner.zip

# Install Node.js & npm
dnf install -y nodejs npm

# Install Snyk
npm install -g snyk

# Install Trivy
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin v0.51.4
trivy --version

# Log Jenkins password
echo "Jenkins Initial Admin Password:" >> /var/log/user-data.log
cat /var/lib/jenkins/secrets/initialAdminPassword >> /var/log/user-data.log

echo "Jenkins setup complete." >> /var/log/user-data.log
