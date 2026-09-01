# Cloud Network Lab

مشروع تجريبي لبناء شبكة AWS داخل LocalStack باستخدام Terraform. يهدف المشروع إلى محاكاة شبكة VPC مع Subnets و Route Tables و Internet Gateway و Security Groups.

## الهيكل

- [terraform/provider.tf](terraform/provider.tf): إعداد موفر AWS مع LocalStack
- [terraform/vpc.tf](terraform/vpc.tf): إنشاء VPC
- [terraform/subnets.tf](terraform/subnets.tf): إنشاء الـ Public و Private و Database subnets
- [terraform/routing.tf](terraform/routing.tf): إنشاء Internet Gateway و Route Tables
- [terraform/security.tf](terraform/security.tf): إنشاء Security Groups
- [docker-compose.yml](docker-compose.yml): تشغيل LocalStack
- [.env](.env): متغيرات البيئة مثل LOCALSTACK_AUTH_TOKEN

## المتطلبات

- Docker
- Docker Compose
- Terraform
- Python 3
- boto3

## تشغيل LocalStack

```bash
cd /workspaces/cloud-network-lab
docker compose up -d
curl -sS http://localhost:4566/_localstack/health
```

## التحقق من الموارد عبر AWS API

```bash
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

print(json.dumps(client.describe_vpcs(), indent=2, default=str))
print(json.dumps(client.describe_subnets(), indent=2, default=str))
PY
```

## تطبيق Terraform

```bash
cd /workspaces/cloud-network-lab/terraform
terraform init
terraform validate
terraform plan
terraform apply -auto-approve
```

## الشبكة المصممة

- VPC رئيسية
- 3 Subnets:
  - Public
  - Private
  - Database
- Internet Gateway
- Public Route Table
- Private Route Table
- Security Groups متعددة

## الملاحظات

- يتم استخدام LocalStack لمحاكاة خدمات AWS محليًا.
- يتم تجاهل ملفات الدولة المحلية مثل `.tfstate` و `.terraform` عبر [.gitignore](.gitignore).
- تم إعداد المشروع بحيث يمكن تطويره بشكل تدريجي داخل بيئة محلية آمنة.

## التوثيق الإضافي

راجع [documentation/architecture.md](documentation/architecture.md) لمزيد من التفاصيل حول البنية الخاصة بالشبكة.
