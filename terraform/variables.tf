variable "aws_profile" {
  description = "The AWS CLI profile to use"
  type        = string
  default     = "dev"
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
  default     = "003"
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


variable "application_port" {
  description = "Port on which the application runs"
  type        = number
  default     = 8080
}

variable "custom_ami" {
  description = "The ID of the custom AMI"
  type        = string
  default     = "ami-0866a3c8686eaeeba"
}

variable "key_pair_name" {
  description = "Name of the SSH key pair to use"
  type        = string
  default     = "ec2-local"
}

variable "db_name" {
  description = "Name of the database engine"
  type        = string
  default     = "csye6225"
}
variable "db_port" {
  description = "Database port number"
  type        = number
  default     = 3306
}
variable "db_identifier" {
  description = "Name of the DB engine"
  type        = string
  default     = "csye6225"
}
variable "db_family" {
  description = "Name of the database engine"
  type        = string
  default     = "mysql"
}
variable "db_engine" {
  description = "Name of the database engine"
  type        = string
  default     = "mysql"
}
variable "db_engine_version" {
  description = "Name of the database engine"
  type        = string
  default     = "8.0.39"
}
variable "db_instance_class" {
  description = "DB instance class"
  type        = string
  default     = "db.t3.micro"
}
variable "db_username" {
  description = "DB instance class"
  type        = string
  default     = "csye6225"
}
variable "db_password" {
  description = "DB instance class"
  type        = string
  default     = "passowrd"
}
variable "domain_name" {
  description = "Domain name for application"
  type        = string
  default     = "www.cloudapplication.com"
}
variable "dev_hosted_zone_id" {
  description = "zone id for dev hosted zone"
  type        = string
  default     = "Z04660987GS3LZNKC1VJ"
}
variable "demo_hosted_zone_id" {
  description = "zone id for demo hosted zone"
  type        = string
  default     = "Z02287832YEL0AQ8CM5PY"
}

variable "tags" {
  description = "Tags to associate with resources"
  type        = map(string)
  default = {
    Environment = "dev"
    Project     = "AWS Infra Setup"
  }
}

variable "sendgrid_api_key" {
  description = "API key for SendGrid email service"
  sensitive   = true
}

variable "email_from_address" {
  description = "Sender email address for the application"
}
variable "lambda_file_path" {
  description = "Email address to subscribe to SNS topic"
  type        = string
}
