variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "The AWS region for provisioning infrastructure resources."
}

variable "environment" {
  type        = string
  default     = "production"
  description = "Deployment environment identifier (e.g. production, staging, localstack)."
}

variable "vpc_cidr" {
  type        = string
  default     = "10.10.10.0/24"
  description = "Primary CIDR block for AetherNet Core VPC."
}

variable "public_subnet_cidr" {
  type        = string
  default     = "10.10.10.0/25"
  description = "CIDR block for public subnet tier."
}

variable "private_subnet_cidr" {
  type        = string
  default     = "10.10.10.128/25"
  description = "CIDR block for isolated private subnet tier."
}

variable "compliance_bucket_name" {
  type        = string
  default     = "aethernet-compliance-ledger"
  description = "S3 compliance tracking bucket name."
}
