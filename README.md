# terraform

# 🌍 Terraform Project

This repository contains Terraform configurations for provisioning infrastructure.

---

## 📦 Prerequisites

- **Terraform** (v1.x or later)
- **AWS CLI** installed and configured with valid credentials
- A GitHub account + SSH setup (if cloning/pushing code)

---

## 🚀 Install Terraform on macOS

### Option 1: Install via Homebrew (Recommended)
```bash
brew update
brew install terraform
terraform -version

### aws configure 
aws configure 
### Sample Screte and Access key   
AKIA2FB89THFDV2AQP45X7	/nUidh90kcwduyn9tCPVPqmevJDuYoSi+TPD+Q


### Option terraform init 

# Initialize Terraform working directory
terraform init

# Validate configuration
terraform validate

# Apply changes automatically (no confirmation)
terraform apply -auto-approve

# Clean up state and lock files (if needed)
rm -rf .terraform/ .terraform.lock.hcl terraform.tfstate terraform.tfstate.backup

# OR destroy the infrastructure
terraform destroy -auto-approve