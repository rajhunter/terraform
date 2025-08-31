variable "region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "instance_name" {
  description = "Name tag for the EC2 instance"
  type        = string
  default     = "customer-service"
}

variable "instance_type" {
  description = "EC2 instance type (t2.micro or t3.micro are free-tier eligible)"
  type        = string
  default     = "t3.micro"
}

variable "key_pair_name" {
  description = "Key pair name for SSH access (Terraform will create this key)"
  type        = string
  default     = "cms-raj-key"
}

variable "allow_ssh_from" {
  description = "CIDR block allowed to access port 22 (SSH). Safer to restrict to your IP/32."
  type        = string
  default     = "0.0.0.0/0"
}
