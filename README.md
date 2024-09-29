# Voice App Terraform Configuration

This repository contains Terraform configuration to deploy the Voice app on AWS EKS with external DNS support.

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform v1.0.0 or later
- kubectl
- helm

## Directory Structure

```
.
├── .github
│   └── workflows
│       └── terraform-apply.yml
├── modules
│   ├── eks
│   │   ├── main.tf
│   │   └── variables.tf
│   ├── external_dns
│   │   ├── main.tf
│   │   └── variables.tf
│   ├── iam
│   │   ├── main.tf
│   │   └── variables.tf
│   ├── vpc
│   │   ├── main.tf
│   │   └── variables.tf
│   └── voice_app
│       ├── main.tf
│       └── variables.tf
├── main.tf
├── variables.tf
├── voice-app-values.yaml
└── README.md
```

## Usage

1. Clone this repository:
   ```
   git clone https://github.com/your-username/voice-app-terraform.git
   cd voice-app-terraform
   ```

2. Initialize Terraform:
   ```
   terraform init
   ```

3. Review and modify the `variables.tf` file to suit your needs.

4. Create a `terraform.tfvars` file with your specific variable values.

5. Plan the Terraform execution:
   ```
   terraform plan
   ```

6. Apply the Terraform configuration:
   ```
   terraform apply
   ```

7. After successful application, configure `kubectl` to interact with your new EKS cluster:
   ```
   aws eks --region eu-central-1 update-kubeconfig --name voice-app-cluster
   ```

## CI/CD

This repository includes a GitHub Actions workflow that automatically plans and applies Terraform changes when commits are pushed to the `main` branch. Make sure to set up the following secrets in your GitHub repository:

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

## Cleanup

To destroy all resources created by Terraform:

```
terraform destroy
```

## Support

For any questions or issues, please open an issue in this repository.
