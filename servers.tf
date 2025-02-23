# Jenkins (Public)
resource "aws_instance" "jenkins" {
  ami                  = "ami-053a45fff0a704a47"
  instance_type        = "t2.large"
  subnet_id            = aws_subnet.public_subnet.id
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
  user_data            = file("scripts/jenkins.sh")
  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
  tags = { 
    Name = "Jenkins-Server" }
}

# Dastardly (Private)
resource "aws_instance" "dastardly" {
  ami                  = "ami-053a45fff0a704a47"
  instance_type        = "t2.medium"
  subnet_id            = aws_subnet.private_subnet.id
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
  user_data            = file("scripts/dastardly.sh")
  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }
  vpc_security_group_ids = [aws_security_group.dastardly_sg.id]
  tags = { 
    Name = "Dastardly-Server" }
}

# OWASP ZAP (Private)
resource "aws_instance" "zap" {
  ami                  = "ami-053a45fff0a704a47"
  instance_type        = "t2.large"
  subnet_id            = aws_subnet.private_subnet.id
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
  user_data            = file("scripts/zap.sh")
  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }
  vpc_security_group_ids = [aws_security_group.zap_sg.id]
  tags = { 
    Name = "ZAP-Server" }
}

# Vault (Private)
resource "aws_instance" "vault" {
  ami                  = "ami-053a45fff0a704a47"
  instance_type        = "t2.medium"
  subnet_id            = aws_subnet.private_subnet.id
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
  user_data            = file("scripts/vault.sh")
  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }
  vpc_security_group_ids = [aws_security_group.vault_sg.id]
  tags = { 
    Name = "Vault-Server" }
}

# Monitoring (Private)
resource "aws_instance" "monitoring" {
  ami                  = "ami-053a45fff0a704a47"
  instance_type        = "t2.large"
  subnet_id            = aws_subnet.private_subnet.id
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
  user_data            = file("scripts/monitoring.sh")
  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }
  vpc_security_group_ids = [aws_security_group.monitoring_sg.id]
  tags = { 
    Name = "Monitoring-Server" }
}
