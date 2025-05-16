# Terraform Continuous Integration

To view the architecture Diargram and other components of the entire project, please refer to this: [Infrastructure and Application Overview](https://github.com/cloud-computing-csye-6225)

This repository uses **Terraform** to manage infrastructure as code (IaC). To ensure code quality and correctness, we've implemented a **Continuous Integration (CI)** pipeline using **GitHub Actions** that automatically checks Terraform configurations for proper formatting and validation every time a pull request (PR) is raised.

## Table of Contents

- [Terraform Continuous Integration](#terraform-continuous-integration)
    - [Table of Contents](#table-of-contents)
    - [Introduction](#introduction)
    - [Requirements](#requirements)
    - [Prerequisites](#prerequisites)
        - [1. Terraform Installation](#1-terraform-installation)
        - [2. AWS CLI Installed](#2-aws-cli-installed)
        - [3. Use AWS Profile with Terraform](#3-use-aws-profile-with-terraform)
    - [CI Workflow Overview](#ci-workflow-overview)
        - [Steps in the Workflow](#steps-in-the-workflow)
    - [Workflow Configuration](#workflow-configuration)
    - [Branch Protection](#branch-protection)
    - [Getting Started](#getting-started)
        - [1. Clone the Repository](#1-clone-the-repository)
        - [2. Create `terraform.tfvars` File](#2-create-terraformtfvars-file)
        - [3. Initialize Terraform](#3-initialize-terraform)
        - [4. Format Terraform Files](#4-format-terraform-files)
        - [5. Validate the Configuration](#5-validate-the-configuration)
        - [6. Plan the terraform](#6-plan-the-terraform)
        - [7. Apply and Destroy your changes(optional)](#7-apply-and-destroy-your-changesoptional)
    - [Contact](#contact)

---

## Introduction

The CI pipeline is triggered for every pull request to the `main` branch. It ensures that:

- Terraform files are properly formatted using `terraform fmt`.
- The configuration is syntactically valid using `terraform validate`.
- The pull request cannot be merged unless the checks pass successfully.

## Requirements

To run this project locally, ensure that the following tools are installed:

- Terraform (version 1.5.0 or later)
- AWS CLI

## Prerequisites

Before working with Terraform and contributing to this repository, ensure you have the following installed and configured on your machine:

### 1. Terraform Installation

- You must have Terraform installed on your machine. Follow the official Terraform installation guide based on your operating system:
- [Terraform Installation Guide](https://learn.hashicorp.com/tutorials/terraform/install-cli)

after installation verify by running code:

```bash
terraform -v
```

### 2. AWS CLI Installed

You need the AWS CLI installed and configured to interact with AWS services. If AWS CLI is not installed, follow the installation guide:

- [AWS CLI Installation Guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

Once installed, you will need to configure it using a custom AWS profile for security and best practices, rather than using the default profile.
Once you have created the cli secret credentials for the user and assigned it enough permissions, set up the CLI, by running the following command:

```bash
aws configure --profile dev
```

Now provide the credentials that you copied from the AWS.

### 3. Use AWS Profile with Terraform

To ensure Terraform uses the custom AWS profile (dev/demo), you need to set the AWS profile environment variable.

```bash
export AWS_PROFILE=dev
```

## CI Workflow Overview

The GitHub Actions workflow file is located in the `.github/workflows/terraform.yml` directory and runs on every pull request to the `main` branch.

### Steps in the Workflow

1. **Checkout Code**: The workflow checks out the repository code.
2. **Terraform Setup**: The workflow installs Terraform CLI using the `hashicorp/setup-terraform` action.
3. **Terraform Init**: Initializes Terraform, downloading necessary providers and modules.
4. **Terraform Formatting Check**: Runs `terraform fmt -check -recursive` to ensure all `.tf` files are formatted according to Terraform standards.
5. **Terraform Validation**: Runs `terraform validate` to check for syntax errors or configuration issues.

## Workflow Configuration

Below is a summary of the GitHub Actions workflow that is used for Terraform validation:

- The Validation of the terraform will be checked
- The Format of all the tf files will be checked.

## Branch Protection
To enforce code quality and prevent broken configurations from being merged into the main branch, GitHub branch protection rules have been enabled. This means that:

* A pull request cannot be merged unless the Terraform CI checks pass.
* The status checks required for merging include terraform fmt and terraform validate.

This ensures that all pull requests are validated and formatted properly before merging.

## Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/your-username/your-repository.git
cd your-repository
```

### 2. Create `terraform.tfvars` File

In the root of your project, you need to create a terraform.tfvars file to provide essential variables for your Terraform configuration. Below is an example of the variables to include:

```hcl
vpc_cidr           = "10.0.0.0/16"  # Replace with your desired CIDR block
aws_region         = "us-east-1"    # Replace with your desired AWS region
privateSubnetCount = 2              # Number of private subnets
publicSubnetCount  = 2              # Number of public subnets
```

### 3. Initialize Terraform

```bash
terraform init
```

### 4. Format Terraform Files

```bash
terraform fmt -recursive
```

### 5. Validate the Configuration

```bash
terraform validate
```

### 6. Plan the terraform

```bash
terraform plan
```

### 7. Apply and Destroy your changes(optional)

If the plan is what is expected, apply your changes using following command:

```bash
terraform apply
```

If your changes are reflecting in the cloud platform, remember to destroy the unnecessary services. U can use below command to destroy what you just created.

```bash
terraform destroy
```

## Contact

For any issues or questions, please reach out at:

* Email: grandhidurga.c@northeastern.edu
* GitHub: https://github.com/chakradhar-grandhi
