# Terraform AWS Infrastructure

This repository contains the Infrastructure-as-Code (IaC) setup using **Terraform** for deploying networking components such as **VPC**, **subnets**, **route tables**, and **internet gateways** on AWS. The repository also includes a **Continuous Integration (CI)** pipeline using **GitHub Actions** to automatically check and validate the Terraform configuration before any code is merged into the main branch.

## Prerequisites

Before you begin, ensure you have the following:
1. **Terraform** installed on your local machine.
2. **AWS CLI** installed and configured with profiles.
3. A **GitHub repository** with **branch protection rules** enabled for PR checks.
