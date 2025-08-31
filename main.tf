###############################################
# Data sources — latest Amazon Linux 2023 AMI
###############################################

data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["137112412989"] # Amazon

  filter {
    name   = "name"
    values = ["al2023-ami-*-kernel-6.1-x86_64"]

  }
}

###############################################
# Key pair — generate one automatically
###############################################

# 1️⃣ Generate a private key
resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# 2️⃣ Upload public key to AWS
resource "aws_key_pair" "this" {
  key_name   = var.key_pair_name
  public_key = tls_private_key.this.public_key_openssh

  lifecycle {
    create_before_destroy = true
  }
}

# 3️⃣ Save private key locally (~/.ssh/<key_name>.pem)
resource "local_file" "pem" {
  content              = tls_private_key.this.private_key_pem
  filename             = "${pathexpand("~/.ssh")}/${var.key_pair_name}.pem"
  file_permission      = "0600"
  directory_permission = "0700"
}


###############################################
# Security group — allow SSH(22) & app(8080)
###############################################

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_security_group" "web_sg" {
  name        = "${var.instance_name}-sg"
  description = "Allow SSH and TCP 8080"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]   
    ipv6_cidr_blocks = ["::/0"]   
  }

  ingress {
    description = "App :8080"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

###############################################
# EC2 instance with user_data (Java only)
###############################################

locals {
  user_data = <<-EOT
    #!/usr/bin/bash
    set -euxo pipefail
    dnf -y update
    dnf -y install java-17-amazon-corretto
  EOT
}

resource "aws_instance" "ec2" {
  ami                         = data.aws_ami.al2023.id
  instance_type               = var.instance_type
  subnet_id                   = element(data.aws_subnets.public.ids, 0)
  associate_public_ip_address = true
  key_name                    = aws_key_pair.this.key_name
  vpc_security_group_ids      = [aws_security_group.web_sg.id]

  #user_data                   = local.user_data
  user_data = <<-EOF
              #!/bin/bash
              # Install EC2 Instance Connect
              dnf install -y ec2-instance-connect
              systemctl enable --now ec2-instance-connect
              EOF

  tags = {
    Name = var.instance_name
  }
}





###############################################
# Outputs
###############################################

output "public_ip" {
  value = aws_instance.ec2.public_ip
}

output "public_dns" {
  value = aws_instance.ec2.public_dns
}


output "ssh_command" {
  value = "ssh -i ~/.ssh/${var.key_pair_name}.pem ec2-user@${aws_instance.ec2.public_ip}"
}

output "scp_command" {
  value = "scp -i ./${var.key_pair_name}.pem \"/Users/raj/Documents/dev-2025/challange/customer-management/target/customer-management-0.0.1-SNAPSHOT.jar\" ec2-user@${aws_instance.ec2.public_ip}:/home/ec2-user/"
}


output "app_url" {
  value = "http://${aws_instance.ec2.public_ip}:8080"
}

