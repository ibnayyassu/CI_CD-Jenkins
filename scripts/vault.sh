#!/bin/bash
sudo su

# Update system
dnf -y update
dnf -y upgrade

# Install Vault
dnf install -y unzip
curl -fsSL https://releases.hashicorp.com/vault/1.15.4/vault_1.15.4_linux_amd64.zip -o /tmp/vault.zip
unzip /tmp/vault.zip -d /usr/local/bin
rm /tmp/vault.zip

# Create Vault config with AWS auth prep
mkdir -p /etc/vault
cat <<EOT > /etc/vault/config.hcl
ui = true
storage "file" {
  path = "/opt/vault/data"
}
listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = 1
}
EOT

# Set up data directory
mkdir -p /opt/vault/data

# Create systemd service
cat <<EOT > /etc/systemd/system/vault.service
[Unit]
Description=HashiCorp Vault
After=network.target

[Service]
ExecStart=/usr/local/bin/vault server -config=/etc/vault/config.hcl
ExecReload=/bin/kill -HUP \$MAINPID
KillMode=process
Restart=on-failure
Environment="VAULT_ADDR=http://127.0.0.1:8200"

[Install]
WantedBy=multi-user.target
EOT

# Start Vault
systemctl enable vault
systemctl start vault

# Install AWS CLI for Vault to interact with AWS
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
unzip /tmp/awscliv2.zip -d /tmp
/tmp/aws/install
rm -rf /tmp/awscliv2.zip /tmp/aws

# Log instructions for manual steps
echo "Vault setup complete." >> /var/log/user-data.log
echo "Next steps (manual):" >> /var/log/user-data.log
echo "1. SSH in: aws ssm start-session --target <instance-id>" >> /var/log/user-data.log
echo "2. Init Vault: export VAULT_ADDR=http://127.0.0.1:8200; vault operator init" >> /var/log/user-data.log
echo "3. Unseal Vault with 3 of 5 keys from init output" >> /var/log/user-data.log
echo "4. Login with root token from init" >> /var/log/user-data.log
echo "5. Enable AWS auth: vault auth enable aws" >> /var/log/user-data.log
echo "6. Configure AWS auth: vault write auth/aws/config/client iam_server_id_header_value=<vault-public-ip>" >> /var/log/user-data.log
echo "7. Create role: vault write auth/aws/role/jenkins-role auth_type=iam bound_iam_principal_arn=${aws_iam_role.vault_sts_role.arn} policies=default ttl=1h" >> /var/log/user-data.log
