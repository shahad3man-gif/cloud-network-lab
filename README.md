# Cloud Network Lab

A practical cloud networking laboratory that simulates a real-world company network using LocalStack, Terraform, Docker, AWS CLI, Python, and Linux.

The project is designed to demonstrate how cloud network infrastructure can be planned, deployed, secured, and validated using Infrastructure as Code (IaC).

---

## Project Overview

The **Cloud Network Lab** simulates a three-tier cloud network architecture similar to an AWS environment.

The architecture separates workloads into:

- Public subnet
- Private subnet
- Database subnet

The project focuses on:

- VPC design
- Subnet segmentation
- Route tables
- Internet Gateway
- Security Groups
- EC2 instances
- Infrastructure as Code
- Terraform
- AWS CLI
- Python and boto3
- Linux
- Docker
- Local cloud simulation
- Network security
- Infrastructure validation

---

## Architecture

The planned architecture follows a three-tier cloud network model.

```text
                         INTERNET
                             |
                             |
                    +--------v--------+
                    | Internet Gateway|
                    +--------+--------+
                             |
                             |
              +--------------v--------------+
              |          VPC                |
              |       10.0.0.0/16           |
              |                             |
              |   +---------------------+   |
              |   |   Public Subnet     |   |
              |   |   10.0.1.0/24       |   |
              |   |                     |   |
              |   |   Web EC2 Server    |   |
              |   +----------+----------+   |
              |              |              |
              |              v              |
              |   +---------------------+   |
              |   |   Private Subnet    |   |
              |   |   10.0.2.0/24       |   |
              |   |                     |   |
              |   |   App EC2 Server    |   |
              |   +----------+----------+   |
              |              |              |
              |              v              |
              |   +---------------------+   |
              |   |   Database Subnet   |   |
              |   |   10.0.3.0/24       |   |
              |   |                     |   |
              |   |   Database Layer    |   |
              |   |   (Planned)         |   |
              |   +---------------------+   |
              |                             |
              +-----------------------------+
```

The architecture follows the principle:

**Internet → Public Layer → Private Application Layer → Database Layer**

---

# Network Design

## VPC

The main virtual network is:

```text
VPC CIDR: 10.0.0.0/16
```

The VPC provides the main network boundary for all cloud resources.

### VPC Configuration

| Component | Configuration |
|---|---|
| VPC | `10.0.0.0/16` |
| DNS Support | Enabled |
| DNS Hostnames | Enabled |
| Region | `us-east-1` |
| Environment | LocalStack |
| Infrastructure Management | Terraform |

---

## Subnet Design

The VPC is divided into multiple subnets.

| Subnet | CIDR | Purpose | Exposure |
|---|---|---|---|
| Public Subnet | `10.0.1.0/24` | Web Server | Internet-facing |
| Private Subnet | `10.0.2.0/24` | Application Server | Internal |
| Database Subnet | `10.0.3.0/24` | Database Layer | Internal |

### Network Segmentation

```text
+---------------------------------------------------+
|                  VPC 10.0.0.0/16                 |
|                                                   |
|  +-------------------+                            |
|  | Public Subnet     |                            |
|  | 10.0.1.0/24       |                            |
|  |                   |                            |
|  | Web Server        |                            |
|  +---------+---------+                            |
|            |                                      |
|            v                                      |
|  +-------------------+                            |
|  | Private Subnet    |                            |
|  | 10.0.2.0/24       |                            |
|  |                   |                            |
|  | App Server        |                            |
|  +---------+---------+                            |
|            |                                      |
|            v                                      |
|  +-------------------+                            |
|  | Database Subnet   |                            |
|  | 10.0.3.0/24       |                            |
|  |                   |                            |
|  | Database          |                            |
|  | Planned           |                            |
|  +-------------------+                            |
|                                                   |
+---------------------------------------------------+
```

---

# Routing Architecture

Routing controls how traffic moves between the different network components.

## Internet Gateway

The VPC uses an Internet Gateway to provide internet connectivity for the public subnet.

```text
INTERNET
    |
    v
Internet Gateway
    |
    v
VPC
    |
    v
Public Route Table
    |
    v
Public Subnet
    |
    v
Web Server
```

The public route table contains:

```text
Destination: 0.0.0.0/0
Target: Internet Gateway
```

This allows resources in the public subnet to communicate with the internet when the required network and security configuration is present.

---

## Private Network Routing

The application subnet does not have a direct route to an Internet Gateway.

```text
+----------------------+
|   Public Subnet      |
|   10.0.1.0/24        |
|                      |
|   Web Server         |
+----------+-----------+
           |
           | Internal Traffic
           v
+----------------------+
|   Private Subnet     |
|   10.0.2.0/24        |
|                      |
|   App Server         |
+----------+-----------+
           |
           | Internal Traffic
           v
+----------------------+
|   Database Subnet    |
|   10.0.3.0/24        |
|                      |
|   Database           |
|   Planned            |
+----------------------+
```

The private subnet is intended to isolate application resources from direct internet exposure.

---

# Security Architecture

The security model follows a layered approach.

```text
                         INTERNET
                             |
                             v
                     +---------------+
                     |   Web Layer   |
                     |   Port 80     |
                     |   Port 443    |
                     +-------+-------+
                             |
                             | Allowed
                             v
                     +---------------+
                     | Application   |
                     |    Layer      |
                     |   Port 8080   |
                     +-------+-------+
                             |
                             | Allowed
                             v
                     +---------------+
                     |  Database     |
                     |    Layer      |
                     |   Port 3306   |
                     +---------------+
```

The objective is to avoid exposing internal resources directly to the internet.

---

# Security Groups

Security Groups are used to control inbound network traffic.

## Web Security Group

The Web Security Group allows web traffic and administrative SSH access.

| Protocol | Port | Source | Purpose |
|---|---:|---|---|
| TCP | 80 | `0.0.0.0/0` | HTTP |
| TCP | 443 | `0.0.0.0/0` | HTTPS |
| TCP | 22 | `0.0.0.0/0` | SSH |

> For a production environment, SSH should be restricted to trusted IP addresses instead of allowing `0.0.0.0/0`.

---

## Application Security Group

The Application Security Group only accepts application traffic from the Web Security Group.

| Protocol | Port | Source | Purpose |
|---|---:|---|---|
| TCP | 8080 | Web Security Group | Application traffic |

This prevents arbitrary internet traffic from directly reaching the application server.

---

## Database Security Group

The Database Security Group only accepts database traffic from the Application Security Group.

| Protocol | Port | Source | Purpose |
|---|---:|---|---|
| TCP | 3306 | App Security Group | MySQL |

### Security Flow

```text
Internet
   |
   | HTTP / HTTPS
   v
Web Security Group
   |
   | TCP 8080
   v
Application Security Group
   |
   | TCP 3306
   v
Database Security Group
```

---

# EC2 Instances

The project includes two EC2 instances in the current implementation.

## Web Server

The Web Server is deployed in the public subnet.

```text
Web Server
Subnet: 10.0.1.0/24
Layer: Public
Purpose: Web Traffic
```

The Web Server is designed to receive external requests.

---

## Application Server

The Application Server is deployed in the private subnet.

```text
Application Server
Subnet: 10.0.2.0/24
Layer: Private
Purpose: Application Processing
Port: 8080
```

The Application Server is intended to receive traffic only from the Web Layer.

---

# Application Traffic Flow

```text
                         INTERNET
                             |
                             v
                    +----------------+
                    |   Web Server   |
                    | Public Subnet  |
                    |  10.0.1.0/24   |
                    +--------+-------+
                             |
                             | TCP 8080
                             v
                    +----------------+
                    |  App Server    |
                    | Private Subnet |
                    |  10.0.2.0/24   |
                    +--------+-------+
                             |
                             | TCP 3306
                             v
                    +----------------+
                    |   Database     |
                    | Database Layer |
                    |  10.0.3.0/24   |
                    +----------------+
```

The database layer is currently planned and is not deployed in the current LocalStack configuration.

---

# Technologies and Tools

| Technology | Purpose |
|---|---|
| Docker | Containerized environment |
| Docker Compose | LocalStack orchestration |
| LocalStack | AWS cloud service simulation |
| Terraform | Infrastructure as Code |
| AWS CLI | AWS resource management |
| awslocal | LocalStack AWS CLI wrapper |
| Python | Automation and validation |
| boto3 | AWS API interaction |
| Linux | Development environment |
| Git | Version control |
| GitHub | Project documentation and portfolio |

---

# Project Structure

```text
cloud-network-lab/
│
├── docker-compose.yml
├── .env
├── .gitignore
├── README.md
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
```

---

# Terraform Configuration

Terraform is used to define and manage the infrastructure.

## provider.tf

The AWS provider is configured to communicate with LocalStack instead of the real AWS environment.

```hcl
provider "aws" {
  region                      = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"

  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    ec2 = "http://localhost:4566"
  }
}
```

---

## vpc.tf

Defines the main VPC.

```text
VPC
CIDR: 10.0.0.0/16
```

The VPC also enables DNS support and DNS hostnames.

---

## subnets.tf

Defines the three logical network segments:

```text
Public:
10.0.1.0/24

Private:
10.0.2.0/24

Database:
10.0.3.0/24
```

---

## routing.tf

Defines:

- Internet Gateway
- Public Route Table
- Private Route Table
- Route associations

The public route table contains:

```text
0.0.0.0/0 → Internet Gateway
```

---

## security.tf

Defines the Security Groups for:

- Web Server
- Application Server
- Database Layer

---

## instances.tf

Defines the EC2 instances.

Current instances:

```text
Web Server
App Server
```

---

## alb.tf

The Application Load Balancer architecture is planned but currently disabled.

The reason is that the required ELBv2 functionality is not available under the current LocalStack license configuration.

Planned architecture:

```text
Internet
    |
    v
Application Load Balancer
    |
    v
Web / Application Targets
```

---

## database.tf

The database layer is planned but currently disabled.

The intended architecture is:

```text
Application Server
       |
       | TCP 3306
       v
Database
```

The current LocalStack environment does not provide the required RDS functionality under the current license configuration.

---

## outputs.tf

Terraform outputs are prepared to expose useful infrastructure information such as:

- VPC ID
- Subnet IDs
- Security Group IDs
- Instance IDs
- Network information

---

# LocalStack Environment

LocalStack provides a local AWS-like environment for testing cloud infrastructure without deploying the resources to a real AWS account.

The environment is started using Docker Compose.

## Start LocalStack

From the project root:

```bash
cd /workspaces/cloud-network-lab
```

Start the containers:

```bash
docker compose up -d
```

The `-d` option starts the container in detached mode.

---

# LocalStack Health Check

After starting LocalStack, verify that the service is running:

```bash
curl -sS http://localhost:4566/_localstack/health
```

The returned status depends on the LocalStack version and available license features.

---

# Terraform Deployment

Move into the Terraform directory:

```bash
cd /workspaces/cloud-network-lab/terraform
```

Initialize Terraform:

```bash
terraform init
```

Format the configuration:

```bash
terraform fmt
```

Validate the configuration:

```bash
terraform validate
```

Expected result:

```text
Success! The configuration is valid.
```

Create an execution plan:

```bash
terraform plan
```

Deploy the infrastructure:

```bash
terraform apply -auto-approve
```

---

# Infrastructure Verification

After Terraform deployment, verify the created resources using `awslocal`.

## Check VPCs

```bash
awslocal ec2 describe-vpcs
```

## Check Subnets

```bash
awslocal ec2 describe-subnets
```

## Check EC2 Instances

```bash
awslocal ec2 describe-instances
```

---

# Verification Flow

```text
Terraform
    |
    v
LocalStack
    |
    +------------------+
    |                  |
    v                  v
   VPC              Subnets
    |                  |
    +---------+--------+
              |
              v
         EC2 Instances
              |
              v
       Security Groups
```

---

# Python and boto3 Verification

Python and boto3 are used to communicate with the AWS-compatible LocalStack API.

Run:

```bash
python3 - <<'PY'
import json
import boto3

client = boto3.client(
    "ec2",
    endpoint_url="http://localhost:4566",
    aws_access_key_id="test",
    aws_secret_access_key="test",
    region_name="us-east-1"
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
```

This validates that Python can communicate with the same infrastructure through the AWS API.

---

# Complete Deployment Workflow

```text
+----------------------+
|       Developer      |
+----------+-----------+
           |
           v
+----------------------+
|      Git / GitHub    |
+----------+-----------+
           |
           v
+----------------------+
|       Terraform      |
+----------+-----------+
           |
           v
+----------------------+
|      LocalStack      |
+----------+-----------+
           |
           v
+----------------------+
|         VPC          |
+----------+-----------+
           |
           +-------------------+
           |                   |
           v                   v
+-------------------+   +-------------------+
|  Public Subnet    |   |  Private Subnet   |
|   10.0.1.0/24     |   |   10.0.2.0/24     |
|                   |   |                   |
|   Web Server      |   |   App Server      |
+-------------------+   +---------+---------+
                                  |
                                  v
                        +-------------------+
                        | Database Subnet   |
                        |   10.0.3.0/24     |
                        |                   |
                        | Database Planned  |
                        +-------------------+
```

---

# Current Implementation

| Component | Status |
|---|---|
| VPC | Implemented |
| Public Subnet | Implemented |
| Private Subnet | Implemented |
| Database Subnet | Defined |
| Internet Gateway | Implemented |
| Public Route Table | Implemented |
| Private Route Table | Implemented |
| Web Security Group | Implemented |
| App Security Group | Implemented |
| Database Security Group | Defined |
| Web EC2 | Implemented |
| App EC2 | Implemented |
| Application Load Balancer | Planned |
| RDS Database | Planned |
| NAT Gateway | Planned |
| Monitoring | Planned |

---

# Current Limitations

## Application Load Balancer

The project architecture includes an Application Load Balancer as a future component.

However, ELBv2 functionality is currently disabled because it is not included in the current LocalStack license configuration.

Planned architecture:

```text
Internet
    |
    v
Application Load Balancer
    |
    +----------------+
    |                |
    v                v
Web/App Server 1   Web/App Server 2
```

---

## Database

The database architecture is also planned.

The intended production-style architecture is:

```text
Web Layer
    |
    v
Application Layer
    |
    v
Database Layer
```

The RDS implementation is currently disabled because the required RDS functionality is not available under the current LocalStack license configuration.

---

# Security and Repository Hygiene

Sensitive and generated files should not be committed to GitHub.

The `.gitignore` file contains entries such as:

```text
.env
.localstack/
.terraform/
*.tfstate
*.tfstate.*
```

The `.env` file may contain environment-specific configuration and should remain local.

Terraform state files should also be excluded from the public repository unless there is a specific reason to commit them.

---

# Validation Strategy

The infrastructure is validated at multiple levels.

```text
                 Infrastructure
                       |
                       v
                Terraform Validate
                       |
                       v
                  Terraform Plan
                       |
                       v
                Terraform Apply
                       |
                       v
              LocalStack Resources
                       |
          +------------+------------+
          |            |            |
          v            v            v
         VPC        Subnets       EC2
          |            |            |
          +------------+------------+
                       |
                       v
                  AWS CLI
                       |
                       v
                    boto3
                       |
                       v
              Infrastructure Check
```

---

# What I Learned

This project provides practical experience in:

### Cloud Networking

- VPC architecture
- CIDR addressing
- Subnet segmentation
- Public and private network design
- Internet Gateway
- Route tables
- Security Groups

### Infrastructure as Code

- Terraform
- Provider configuration
- Resource dependencies
- Terraform state
- Terraform validation
- Terraform planning
- Infrastructure deployment

### Cloud Simulation

- LocalStack
- AWS-compatible APIs
- Docker
- Docker Compose
- Local cloud environments

### Automation

- Python
- boto3
- AWS CLI
- awslocal
- Infrastructure verification

### Linux

- Terminal-based development
- Docker management
- Environment configuration
- CLI troubleshooting

### Security

- Network segmentation
- Layered security
- Security Groups
- Controlled service-to-service communication
- Private application architecture

---

# Future Improvements

The project roadmap includes:

- [ ] Enable Application Load Balancer
- [ ] Add database implementation
- [ ] Add NAT Gateway
- [ ] Add multiple application instances
- [ ] Add load balancing
- [ ] Add CloudWatch-style monitoring
- [ ] Add centralized logging
- [ ] Add automated infrastructure testing
- [ ] Add CI/CD pipeline
- [ ] Add GitHub Actions
- [ ] Add network traffic testing
- [ ] Add HTTPS/TLS
- [ ] Improve SSH security
- [ ] Add architecture diagrams
- [ ] Add automated documentation
- [ ] Deploy an equivalent architecture on real AWS

---

# Project Roadmap

```text
Phase 1
Network Design
     |
     v
Phase 2
VPC + Subnets
     |
     v
Phase 3
Routing
     |
     v
Phase 4
Security Groups
     |
     v
Phase 5
EC2 Infrastructure
     |
     v
Phase 6
Terraform Automation
     |
     v
Phase 7
Infrastructure Validation
     |
     v
Phase 8
Load Balancer
     |
     v
Phase 9
Database
     |
     v
Phase 10
Monitoring + CI/CD
     |
     v
Phase 11
Real AWS Deployment
```

---

# Skills Demonstrated

```text
                 CLOUD NETWORKING
                        |
        +---------------+---------------+
        |               |               |
        v               v               v
       VPC           SUBNETS         ROUTING
        |               |               |
        +---------------+---------------+
                        |
                        v
                   SECURITY
                        |
                        v
                    TERRAFORM
                        |
                        v
                   LOCALSTACK
                        |
             +----------+----------+
             |                     |
             v                     v
           DOCKER               PYTHON
             |                     |
             +----------+----------+
                        |
                        v
                    GITHUB
```

---

# Project Status

**Current Status: In Progress**

The core cloud networking infrastructure has been implemented and tested in a local AWS-compatible environment.

### Implemented

- VPC
- Subnet architecture
- Internet Gateway
- Route tables
- Security Groups
- EC2 instances
- Terraform configuration
- LocalStack environment
- Docker Compose environment
- AWS CLI validation
- Python/boto3 validation

### Planned

- Application Load Balancer
- RDS database
- NAT Gateway
- Monitoring
- Logging
- CI/CD
- Real AWS deployment

---

# Author

**Shahad Saleh Juma Al Sinani**

Computer Science — Systems & Networks

Focus:

- Cloud Networking
- Network Infrastructure
- Infrastructure as Code
- Cloud Computing
- Network Security
- Linux
- Automation

---

# Key Takeaway

The project demonstrates the complete infrastructure lifecycle:

```text
DESIGN
  |
  v
NETWORK ARCHITECTURE
  |
  v
INFRASTRUCTURE AS CODE
  |
  v
LOCAL CLOUD SIMULATION
  |
  v
DEPLOYMENT
  |
  v
SECURITY
  |
  v
VALIDATION
  |
  v
AUTOMATION
  |
  v
FUTURE AWS DEPLOYMENT
```

> This project demonstrates practical cloud networking and Infrastructure as Code skills by designing, deploying, securing, and validating an AWS-like network environment locally using Terraform and LocalStack.
