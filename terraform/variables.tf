variable "aws_profile" {
  description = "The AWS CLI profile to use"
  type        = string
  default     = "demo"
}

variable "region" {
  description = "The AWS region to deploy in"
  default     = "us-east-1"
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
  default     = "my-vpc"
}

variable "unique_suffix" {
  description = "Unique suffix to ensure resource names are unique"
  type        = string
  default     = "001"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR blocks for the public subnets"
  type        = string
  default     = "10.0.1.0/24"
}



variable "application_port" {
  description = "Port on which the application runs"
  type        = number
  default     = 8080
}

variable "custom_ami" {
  description = "The ID of the custom AMI"
  type        = string
}

variable "key_pair_name" {
  description = "Name of the SSH key pair to use"
  type        = string
}