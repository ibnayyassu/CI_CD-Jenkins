# Jenkins Security Group
resource "aws_security_group" "jenkins_sg" {
  vpc_id = aws_vpc.pipeline_vpc.id
  name   = "jenkins-sg"
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Restrict in prod
  }
  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Use your IP in prod
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "jenkins-sg" }
}

# Dastardly Security Group
resource "aws_security_group" "dastardly_sg" {
  vpc_id = aws_vpc.pipeline_vpc.id
  name   = "dastardly-sg"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.jenkins_sg.id]  # Jenkins SSH only
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "dastardly-sg" }
}

# OWASP ZAP Security Group
resource "aws_security_group" "zap_sg" {
  vpc_id = aws_vpc.pipeline_vpc.id
  name   = "zap-sg"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.jenkins_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "zap-sg" }
}

# Vault Security Group
resource "aws_security_group" "vault_sg" {
  vpc_id = aws_vpc.pipeline_vpc.id
  name   = "vault-sg"
  ingress {
    from_port   = 8200
    to_port     = 8200
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Restrict to VPC in prod
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "vault-sg" }
}

resource "aws_security_group" "monitoring_sg" {
  vpc_id = aws_vpc.pipeline_vpc.id
  name   = "monitoring-sg"
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    security_groups = [aws_security_group.jenkins_sg.id]  # Jenkins access to Grafana
  }
  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    security_groups = [aws_security_group.jenkins_sg.id]  # Jenkins access to Prometheus
  }
  ingress {
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["10.230.0.0/16"]  # Allow all instances in VPC to send Node Exporter metrics
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # SSM for practice
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "monitoring-sg" }
}
