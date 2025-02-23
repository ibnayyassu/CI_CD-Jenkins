# Jenkins Outputs
output "jenkins_instance_id" {
  value       = aws_instance.jenkins.id
  description = "The instance ID of the Jenkins server for SSM access"
}

output "jenkins_public_ip" {
  value       = aws_instance.jenkins.public_ip
  description = "The public IP of the Jenkins server for UI access"
}

# Dastardly Outputs
output "dastardly_instance_id" {
  value       = aws_instance.dastardly.id
  description = "The instance ID of the Dastardly server for SSM access"
}

output "dastardly_public_ip" {
  value       = aws_instance.dastardly.private_ip
  description = "The public IP of the Dastardly server for SSH from Jenkins"
}

# OWASP ZAP Outputs
output "zap_instance_id" {
  value       = aws_instance.zap.id
  description = "The instance ID of the OWASP ZAP server for SSM access"
}

output "zap_public_ip" {
  value       = aws_instance.zap.private_ip
  description = "The public IP of the OWASP ZAP server for SSH from Jenkins"
}

# Vault Outputs
output "vault_instance_id" {
  value       = aws_instance.vault.id
  description = "The instance ID of the Vault server for SSM access"
}

output "vault_public_ip" {
  value       = aws_instance.vault.private_ip
  description = "The public IP of the Vault server for Jenkins integration"
}

# Monitoring Outputs
output "monitoring_instance_id" {
  value       = aws_instance.monitoring.id
  description = "The instance ID of the Monitoring server for SSM access"
}

output "monitoring_public_ip" {
  value       = aws_instance.monitoring.private_ip
  description = "The public IP of the Monitoring server for Grafana/Prometheus UI"
}

# Optional: Vault STS Role ARN (for Vault setup)
output "vault_sts_role_arn" {
  value       = aws_iam_role.vault_sts_role.arn
  description = "The ARN of the Vault STS role for configuring AWS auth in Vault"
}
