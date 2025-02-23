provider "aws" {
  region = "us-east-1"  # Change to your preferred region
}

# VPC
resource "aws_vpc" "pipeline_vpc" {
  cidr_block           = "10.230.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = { 
    Name = "pipeline-vpc" }
}

# Subnet (Public)
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.pipeline_vpc.id
  cidr_block              = "10.230.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"  # Adjust AZ
  tags = { 
    Name = "pipeline-public-subnet" }
}

# Private Subnet (Vault, Dastardly, ZAP, Monitoring)
resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.pipeline_vpc.id
  cidr_block              = "10.230.11.0/24"
  map_public_ip_on_launch = false
  availability_zone       = "us-east-1a"
  tags                    = { Name = "pipeline-private-subnet" }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.pipeline_vpc.id
  tags   = { 
    Name = "pipeline-igw" }
}

# Route Table(public)
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.pipeline_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { 
    Name = "pipeline-public-rt" }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# NAT Gateway (for Private Subnet)
resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet.id
  tags          = { Name = "pipeline-nat" }
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.pipeline_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  tags = { Name = "pipeline-private-rt" }
}

resource "aws_route_table_association" "private_assoc" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_rt.id
}

# IAM Role for EC2
resource "aws_iam_role" "ec2_role" {
  name = "pipeline-ec2-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

# Vault STS Role
resource "aws_iam_role" "vault_sts_role" {
  name = "vault-sts-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { AWS = aws_iam_role.ec2_role.arn }
    }]
  })
}

# STS Policy for Projects
resource "aws_iam_policy" "vault_sts_policy" {
  name = "vault-sts-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:*",                    
          "rds:*",                   
          "dynamodb:*",           
          "ec2:*",                  
          "transitgateway:*",       
          "sagemaker:*",            
          "comprehendmedical:*",    
          "kms:*",                  
          "iam:PassRole",           
          "iam:GetRole",
          "cloudwatch:*",           
          "logs:*"                  
        ]
        Effect   = "Allow"
        Resource = "*"              
      }
    ]
  })
}

# Attach policy
resource "aws_iam_role_policy_attachment" "vault_sts_policy_attach" {
  role       = aws_iam_role.vault_sts_role.name
  policy_arn = aws_iam_policy.vault_sts_policy.arn
}

resource "aws_iam_role_policy_attachment" "cloudwatch_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "pipeline-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

# EC2 STS Policy with iam:GetRole
resource "aws_iam_role_policy" "ec2_sts_policy" {
  name = "ec2-sts-policy"
  role = aws_iam_role.ec2_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "sts:AssumeRole"
        Effect   = "Allow"
        Resource = aws_iam_role.vault_sts_role.arn
      },
      {
        Action   = "iam:GetRole"
        Effect   = "Allow"
        Resource = aws_iam_role.vault_sts_role.arn  # Specific to vault-sts-role
      }
    ]
  })
}
