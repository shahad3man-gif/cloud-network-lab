☁️ Cloud Network Lab

«AWS-like Cloud Network Infrastructure built locally using Terraform, LocalStack, Docker, and Python/boto3.»

A practical cloud networking laboratory designed to simulate a small enterprise AWS network locally. The project focuses on Cloud Networking, Infrastructure as Code (IaC), network segmentation, routing, security, AWS API interaction, and infrastructure validation without requiring deployment to a real AWS account.

---

📌 Project Overview

The Cloud Network Lab is a simulated AWS networking environment running locally through LocalStack.

The infrastructure is provisioned using Terraform, while Docker Compose manages the LocalStack environment. After deployment, the infrastructure is validated through AWS-compatible CLI commands and Python/boto3.

The project was designed to understand how different cloud networking components work together in a real-world architecture.

Main objectives

- Design a structured cloud network.
- Implement network segmentation using multiple subnets.
- Separate public-facing and internal application resources.
- Configure routing between network components.
- Apply security rules using Security Groups.
- Deploy EC2-based workloads.
- Practice Infrastructure as Code using Terraform.
- Interact with AWS-compatible APIs locally.
- Validate infrastructure after deployment.
- Troubleshoot service limitations and document technical decisions.

---

🏗️ Architecture

The current architecture consists of a VPC divided into three logical network tiers:

                         🌐 Internet
                              │
                              ▼
                    ┌─────────────────┐
                    │ Internet Gateway│
                    │      (IGW)      │
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │       VPC       │
                    │   10.0.0.0/16   │
                    │                 │
        ┌───────────┼─────────┬───────┘
        │           │         │
        ▼           ▼         ▼
 ┌────────────┐ ┌──────────┐ ┌──────────────┐
 │   Public   │ │ Private  │ │   Database   │
 │   Subnet   │ │  Subnet  │ │    Subnet    │
 │10.0.1.0/24 │ │10.0.2.0/24│ │10.0.3.0/24 │
 │            │ │          │ │              │
 │ Web Server │ │App Server│ │Database Tier │
 │    EC2     │ │   EC2    │ │   Planned    │
 └────────────┘ └──────────┘ └──────────────┘

Network CIDR Plan

Component| CIDR| Purpose
VPC| "10.0.0.0/16"| Main virtual network
Public Subnet| "10.0.1.0/24"| Public-facing resources
Private Subnet| "10.0.2.0/24"| Internal application resources
Database Subnet| "10.0.3.0/24"| Database layer

---

🔐 Security Architecture

The network follows a basic tiered security model.

Web Security Group

Allows:

Protocol| Port| Purpose
HTTP| 80| Web traffic
HTTPS| 443| Secure web traffic
SSH| 22| Administrative access

Application Security Group

Allows application traffic on:

TCP 8080

The intended source is the Web Security Group, rather than unrestricted Internet access.

Web Server
     │
     │ TCP/8080
     ▼
App Server

Database Security Group

The planned database layer uses:

TCP 3306

with traffic intended to originate from the Application Security Group.

App Server
     │
     │ TCP/3306
     ▼
Database

This creates the following logical communication flow:

Internet
   │
   ▼
Web Tier
   │
   ▼
Application Tier
   │
   ▼
Database Tier

This approach demonstrates the principle of network segmentation and reduces unnecessary direct exposure of internal resources.

---

🧩 Technologies & Tools

Technology| Role
Terraform| Infrastructure as Code
LocalStack| Local AWS service simulation
Docker| Containerized LocalStack environment
Docker Compose| LocalStack service configuration
Python 3| Infrastructure verification
boto3| AWS API interaction
AWS CLI / awslocal| Command-line resource inspection
Linux Terminal| Environment management and execution
Git / GitHub| Version control and project documentation

---

📁 Project Structure

cloud-network-lab/
│
├── docker-compose.yml
├── .env
├── .gitignore
│
├── terraform/
│   ├── provider.tf
│   ├── vpc.tf
│   ├── subnets.tf
│   ├── routing.tf
│   ├── security.tf
│   ├── instances.tf
│   ├── alb.tf
│   ├── database.tf
│   └── outputs.tf
│
└── documentation/
    └── architecture.md

---

📄 Terraform Files

"provider.tf"

Configures the Terraform AWS provider to communicate with LocalStack instead of the real AWS environment.

Architecture:

Terraform
    │
    ▼
AWS Provider
    │
    ▼
LocalStack
    │
    ▼
AWS-compatible APIs

---

"vpc.tf"

Defines the main VPC:

CIDR: 10.0.0.0/16

and enables DNS support and DNS hostnames.

---

"subnets.tf"

Defines the network segmentation:

Public    → 10.0.1.0/24
Private   → 10.0.2.0/24
Database  → 10.0.3.0/24

---

"routing.tf"

Defines:

- Internet Gateway
- Route Tables
- Route Table Associations
- Internet routing

The public route table uses:

Destination: 0.0.0.0/0
Target: Internet Gateway

---

"security.tf"

Defines the Security Groups for:

- Web tier
- Application tier
- Database tier

The rules are designed to restrict communication between tiers.

---

"instances.tf"

Defines the EC2-based workloads:

Web Server  → Public Subnet
App Server  → Private Subnet

---

"alb.tf"

Reserved for the planned Application Load Balancer implementation.

The ALB configuration is currently disabled because the required ELBv2 functionality is not available under the LocalStack license currently being used.

---

"database.tf"

Reserved for the planned RDS database layer.

The RDS configuration is currently disabled because RDS functionality is not available under the current LocalStack license.

---

"outputs.tf"

Prepared to expose important infrastructure information such as:

- VPC ID
- Subnet IDs
- Instance IDs
- IP addresses

---

🚀 Getting Started

1. Prerequisites

Install or have access to:

- Docker
- Docker Compose
- Terraform
- Python 3
- boto3
- Git
- AWS CLI / awslocal

---

2. Clone the Repository

git clone <YOUR_REPOSITORY_URL>
cd cloud-network-lab

---

3. Start LocalStack

docker compose up -d

This starts the LocalStack environment in the background.

Check the running containers:

docker ps

---

4. Check LocalStack Health

Run:

curl -sS http://localhost:4566/_localstack/health

The response should indicate that the required services are available/running.

---

5. Initialize Terraform

Move to the Terraform directory:

cd terraform

Initialize the Terraform working directory:

terraform init

This downloads and initializes the required Terraform provider configuration.

---

6. Format Terraform Configuration

terraform fmt

This formats the Terraform files according to Terraform's standard formatting rules.

---

7. Validate the Configuration

terraform validate

Expected result:

Success! The configuration is valid.

This confirms that the Terraform configuration can be parsed and validated successfully.

---

8. Review the Infrastructure Plan

terraform plan

Terraform compares the desired infrastructure configuration with the current state and displays the resources that would be created, modified, or destroyed.

---

9. Deploy the Infrastructure

terraform apply -auto-approve

Terraform then provisions the configured infrastructure through LocalStack.

---

🔎 Infrastructure Verification

After deployment, the resources can be inspected through AWS-compatible APIs.

Check VPCs

awslocal ec2 describe-vpcs

Check Subnets

awslocal ec2 describe-subnets

Check EC2 Instances

awslocal ec2 describe-instances

---

🐍 Verification Using Python & boto3

The infrastructure can also be verified programmatically using Python.

python3 - <<'PY'
import json
import boto3

client = boto3.client(
    'ec2',
    endpoint_url='http://localhost:4566',
    aws_access_key_id='test',
    aws_secret_access_key='test',
    region_name='us-east-1'
)

print("=== VPCs ===")
print(json.dumps(
    client.describe_vpcs(),
    indent=2,
    default=str
))

print("=== Subnets ===")
print(json.dumps(
    client.describe_subnets(),
    indent=2,
    default=str
))

print("=== Instances ===")
print(json.dumps(
    client.describe_instances(),
    indent=2,
    default=str
))
PY

This provides an additional verification layer:

Terraform
    │
    ▼
LocalStack
    │
    ▼
AWS-compatible API
    │
    ▼
boto3
    │
    ▼
Resource Verification

---

🧪 Validation Workflow

The project follows this general workflow:

┌──────────────────────┐
│   Project Files      │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│ Docker Compose       │
│ Start LocalStack     │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│ LocalStack Health    │
│ Check                │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│ Terraform Init       │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│ Terraform Validate   │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│ Terraform Plan       │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│ Terraform Apply      │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│ AWS API Verification │
│ boto3 / awslocal     │
└──────────────────────┘

---

⚠️ Current Limitations

This project uses LocalStack as an AWS simulation environment.

Some AWS services depend on the LocalStack edition and license configuration.

Application Load Balancer

The ALB implementation was planned but temporarily disabled because ELBv2 functionality is not included in the currently available LocalStack license.

Amazon RDS

The RDS implementation was also planned but temporarily disabled because RDS functionality is not included in the currently available LocalStack license.

These limitations do not change the networking concepts demonstrated by the project. The corresponding components remain part of the planned architecture and can be implemented when the required services become available or when deploying to real AWS infrastructure.

---

🔒 Security & Repository Hygiene

The repository uses ".gitignore" to prevent local and sensitive files from being committed.

Examples include:

.env
.localstack/
.terraform/
*.tfstate
*.tfstate.*

This is particularly important for preventing accidental exposure of:

- Environment variables
- Authentication tokens
- Terraform state
- Local development files

---

📚 What I Learned

Through this project, I practiced and strengthened my understanding of:

Cloud Networking

- VPC design
- CIDR addressing
- Subnetting
- Public vs. private networks
- Internet Gateway
- Route Tables
- Network segmentation

Cloud Security

- Security Groups
- Tier-based access control
- Restricting internal services
- Reducing unnecessary network exposure

Infrastructure as Code

- Terraform configuration
- Providers
- Resources
- Dependencies
- "terraform init"
- "terraform fmt"
- "terraform validate"
- "terraform plan"
- "terraform apply"

Cloud Tooling

- Docker
- Docker Compose
- LocalStack
- AWS CLI
- AWS APIs
- Python
- boto3

Troubleshooting

The project also provided practical experience in identifying infrastructure limitations, understanding service availability, modifying the implementation accordingly, and documenting technical decisions.

---

🔮 Future Improvements

The next iterations of the project will focus on moving from a basic cloud networking lab toward a more production-oriented architecture.

Planned improvements include:

- [ ] Application Load Balancer
- [ ] RDS database layer
- [ ] NAT Gateway
- [ ] Network ACLs
- [ ] Multi-AZ architecture
- [ ] VPC Flow Logs
- [ ] CloudWatch monitoring
- [ ] IAM roles and policies
- [ ] Bastion Host / secure administrative access
- [ ] Terraform modules
- [ ] Terraform remote state
- [ ] CI/CD pipeline for Terraform
- [ ] High Availability architecture
- [ ] Deployment to real AWS
- [ ] Network monitoring and logging

---

🎯 Project Goals

The long-term goal is to evolve this laboratory into a more complete Cloud Network Engineering portfolio project demonstrating:

Cloud Networking
       +
Infrastructure as Code
       +
Cloud Security
       +
Automation
       +
Monitoring
       +
High Availability
       +
AWS

---

👩‍💻 Author

Shahad Saleh Juma Al Sinani

Computer Science — Systems & Networks

Interested in:

- Cloud Networking
- Cloud Infrastructure
- Network Security
- Infrastructure as Code
- AWS
- Network Automation

---

⭐ Project Status

Status: 🟢 Active Development

The current version successfully demonstrates the core network architecture using LocalStack and Terraform.

The project will continue to evolve toward a more production-oriented AWS cloud networking environment.

---

📌 Key Takeaway

This project demonstrates the complete infrastructure lifecycle:

Design
  ↓
Infrastructure as Code
  ↓
Local Deployment
  ↓
Network Configuration
  ↓
Security Configuration
  ↓
API Verification
  ↓
Troubleshooting
  ↓
Documentation

«The purpose of this project is not only to build a cloud network, but to understand how cloud infrastructure is designed, provisioned, secured, validated, and evolved.»
