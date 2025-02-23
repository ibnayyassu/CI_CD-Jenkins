#!/bin/bash
sudo su
dnf -y update
dnf -y upgrade
dnf install -y java-17-amazon-corretto
curl -L https://github.com/zaproxy/zaproxy/releases/download/v2.15.0/ZAP_2.15.0_Linux.tar.gz -o /tmp/zap.tar.gz
tar -xzf /tmp/zap.tar.gz -C /opt/
mv /opt/ZAP_2.15.0 /opt/zap
rm /tmp/zap.tar.gz
ln -s /opt/zap/zap.sh /usr/local/bin/zap
cat << 'EOF' > /opt/zap/scan.sh
#!/bin/bash
/opt/zap/zap.sh -cmd -quickurl "$1" -quickout /tmp/zap-report.html
EOF
chmod 755 /opt/zap/scan.sh
echo "OWASP ZAP setup complete." >> /var/log/user-data.log
