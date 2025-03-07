# Wiz Attack Simulations

Repository of Terraform templates for Wiz Sensor and Wiz Defend Attack Simulations. This repository contains infrastructure-as-code templates to deploy environments for testing and demonstrating Wiz security capabilities.

## Repository Structure

This repository contains two main Terraform modules:

- **EC2**: Deploy an EC2 instance with Wiz Sensor and attack simulation tools
- **ECS Fargate**: Deploy ECS Fargate tasks with Wiz Sensor for containerized attack simulations

## EC2 Module

The EC2 module (`/ec2`) deploys an AWS EC2 instance with the Wiz Sensor and various attack simulation tools pre-installed.

### Resources Deployed

- VPC with public and private subnets
- Internet Gateway and route tables
- Security group allowing SSH access
- EC2 instance with Ubuntu 24.04
- IAM role and instance profile with SSM access
- SSM parameters for Wiz API credentials
- SSH key pair (optional)

### Pre-installed Tools

- Wiz Sensor
- AWS CLI
- Stratus Red Team (attack simulation tool)
- Pacu (AWS exploitation framework)

### Variables

| Variable | Description | Default |
|----------|-------------|---------|
| aws_region | AWS region to deploy resources | us-east-1 |
| availability_zones | List of availability zones | ["us-east-1a", "us-east-1b"] |
| vpc_cidr | CIDR block for VPC | 10.0.0.0/16 |
| instance_type | EC2 instance type | t2.micro |
| wiz_api_client_id | Wiz API Client ID (sensitive) | - |
| wiz_api_client_secret | Wiz API Client Secret (sensitive) | - |
| key_pair_name | Name of existing key pair to use | "" |
| public_key | Public key material for new key pair | "" |

### Usage

1. Navigate to the EC2 directory:
   ```
   cd ec2
   ```

2. Create a `terraform.tfvars` file with your configuration:
   ```
   aws_region = "us-east-1"
   instance_type = "t2.micro"
   wiz_api_client_id = "your-wiz-client-id"
   wiz_api_client_secret = "your-wiz-client-secret"
   ```

3. Initialize and apply the Terraform configuration:
   ```
   terraform init
   terraform apply
   ```

## ECS Fargate Module

The ECS Fargate module (`/ecs-fargate`) deploys AWS ECS Fargate tasks with the Wiz Sensor for containerized attack simulations.

### Resources Deployed

- VPC with public and private subnets
- Internet Gateway and route tables
- ECS Cluster
- ECS Task Definitions for attack scenarios
- IAM roles for task execution and task permissions
- CloudWatch Log Groups
- Secrets Manager for container registry credentials

### Variables

| Variable | Description | Default |
|----------|-------------|---------|
| aws_region | AWS region to deploy resources | us-east-1 |
| ecs_cluster_name | Name of the ECS cluster | wiz-cluster |
| sensor_pullkey_username | Username for Wiz container registry | - |
| sensor_pullkey_password | Password for Wiz container registry | - |
| wiz_api_client_id | Wiz API Client ID | - |
| wiz_api_client_secret | Wiz API Client Secret | - |
| wiz_fargate_attack_scenario_command | Command to run for attack simulation | - |

### Usage

1. Navigate to the ECS Fargate directory:
   ```
   cd ecs-fargate
   ```

2. Create a `terraform.tfvars` file with your configuration:
   ```
   aws_region = "us-east-1"
   ecs_cluster_name = "wiz-cluster"
   sensor_pullkey_username = "your-registry-username"
   sensor_pullkey_password = "your-registry-password"
   wiz_api_client_id = "your-wiz-client-id"
   wiz_api_client_secret = "your-wiz-client-secret"
   wiz_fargate_attack_scenario_command = "your-attack-command"
   ```

3. Initialize and apply the Terraform configuration:
   ```
   terraform init
   terraform apply
   ```

## Prerequisites

- AWS account with appropriate permissions
- Terraform v1.0.0 or newer
- Wiz account with API credentials
- For ECS Fargate: Access to Wiz container registry

## Security Considerations

- The deployed resources are intended for security testing and demonstrations
- Ensure proper IAM permissions and network security controls
- Do not deploy in production environments without proper security review
- Credentials are stored in AWS SSM Parameter Store or Secrets Manager

## Cleanup

To remove all deployed resources:

```
terraform destroy
```