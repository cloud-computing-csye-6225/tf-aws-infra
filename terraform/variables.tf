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

variable "public_subnet_cidrs" {
  description = "CIDR blocks for the public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for the private subnets"
  type        = list(string)
  default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

variable "tags" {
  description = "Tags to associate with resources"
  type        = map(string)
  default = {
    Environment = "demo"
    Project     = "AWS VPC Setup"
  }
}
