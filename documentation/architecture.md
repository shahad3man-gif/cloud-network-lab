# Architecture Overview

## Goal

This lab builds a small AWS-like network environment using LocalStack and Terraform. The goal is to simulate a public/private network topology that mirrors a production-ready cloud architecture while staying local to the machine.

## Components

### VPC
The project creates one VPC with CIDR range `10.0.0.0/16`.

### Subnets
Three subnets are created:

- Public subnet: `10.0.1.0/24`
- Private subnet: `10.0.2.0/24`
- Database subnet: `10.0.3.0/24`

### Routing
An Internet Gateway is attached to the VPC. The public route table sends `0.0.0.0/0` traffic through the IGW. The private and database route tables are isolated from direct internet access.

### Security Groups
Three security groups are configured:

- Web SG: allows HTTP, HTTPS, and SSH
- App SG: allows traffic only from the web layer on port 8080
- Database SG: allows traffic only from the app layer on port 3306

## LocalStack

LocalStack runs the AWS-like endpoints locally on port 4566. Terraform is configured to target the LocalStack endpoint instead of the real AWS cloud.

## Verification

The environment is verified by checking:

- the LocalStack health endpoint
- EC2 VPC and subnet listings via boto3
- Terraform validation and apply output

## Notes

This setup is meant for learning, prototyping, and lab validation rather than production deployment.
