# Cloud Network Lab

مشروع تعليمي ومهني لبناء شبكة AWS محاكاة داخل LocalStack باستخدام Terraform. يركز المشروع على تصميم بنية شبكات في السحابة بطريقة عملية، مع التحقق من صحة التكوين والتفاعل مع الـ AWS APIs المحلية.

## 1. الهدف من المشروع

الهدف الأساسي هو بناء بيئة شبكة محلية تشبه AWS بشكل كبير، ومشغلة عبر LocalStack، بحيث يمكن:

- إنشاء VPC داخل بيئة محلية
- إنشاء Subnets متعددة
- ربطها بـ Route Tables و Internet Gateway
- تطبيق Security Groups
- إنشاء EC2 instances داخل الشبكات المناسبة
- اختبار الوصول عبر AWS APIs المحلية
- التحقق من أن Terraform يطبق البنية بشكل صحيح قبل الانتقال إلى AWS الحقيقي

هذا المشروع مناسب للتعلم، التجريب، ومراجعة مفاهيم الشبكات السحابية والIaC.

## 2. بنية المشروع

### مجلدات المشروع

- [docker-compose.yml](docker-compose.yml): ملف إعداد LocalStack
- [.env](.env): متغيرات البيئة مثل `LOCALSTACK_AUTH_TOKEN`
- [terraform/](terraform/): جميع ملفات Terraform
- [documentation/](documentation/): ملفات توثيق إضافية
- [.gitignore](.gitignore): تجاهل الملفات المؤقتة مثل `.terraform` و `*.tfstate`

### ملفات Terraform الأساسية

- [terraform/provider.tf](terraform/provider.tf): إعداد موفر AWS في LocalStack
- [terraform/vpc.tf](terraform/vpc.tf): إنشاء VPC
- [terraform/subnets.tf](terraform/subnets.tf): إنشاء Public / Private / Database subnets
- [terraform/routing.tf](terraform/routing.tf): إنشاء Internet Gateway و Route Tables
- [terraform/security.tf](terraform/security.tf): إنشاء Security Groups
- [terraform/instances.tf](terraform/instances.tf): إنشاء EC2 instance للـ Web و App
- [terraform/alb.tf](terraform/alb.tf): تم إلغاءه مؤقتًا لأن LocalStack الحالي لا يدعم ELBv2 ضمن الترخيص المتاح
- [terraform/database.tf](terraform/database.tf): تم التعليق عليه مؤقتًا لأن LocalStack الحالي لا يدعم RDS ضمن الترخيص الحالي
- [terraform/outputs.tf](terraform/outputs.tf): جاهز للإضافة لاحقًا لعرض القيم المهمة مثل IDs و IPs

## 3. الشبكة المصممة

### VPC
- CIDR: `10.0.0.0/16`
- تمكين DNS support و DNS hostnames

### Subnets
- Public subnet: `10.0.1.0/24`
- Private subnet: `10.0.2.0/24`
- Database subnet: `10.0.3.0/24`

### Routing
- Internet Gateway داخل VPC
- Route table عام يوجه `0.0.0.0/0` إلى الـ IGW
- Route table خاص للحركة الداخلية

### Security Groups
- Web SG: يسمح بالـ HTTP و HTTPS و SSH
- App SG: يسمح فقط للاتصال من Web SG عبر الـ 8080
- DB SG: يسمح فقط للاتصال من App SG عبر الـ 3306

### EC2 instances
- Web Server في Public subnet
- App Server في Private subnet

## 4. المتطلبات

قبل تشغيل المشروع، تأكد من توفر التالي:

- Docker
- Docker Compose
- Terraform
- Python 3
- boto3
- Git

## 5. إعداد LocalStack

### 1) تفعيل الحاوية

```bash
cd /workspaces/cloud-network-lab
docker compose up -d
```

### 2) التحقق من الصحة

```bash
curl -sS http://localhost:4566/_localstack/health
```

### مثال على الاستجابة المتوقعة

```json
{
  "services": {
    "ec2": "running",
    "iam": "available",
    "elbv2": "available",
    "rds": "available"
  },
  "edition": "pro",
  "version": "2026.8.0"
}
```

## 6. التحقق من وجود الموارد عبر API

يمكن استخدام boto3 مباشرة للتأكد من أن VPC و Subnets و EC2 موجودة فعليًا عبر AWS API المحلية.

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
print(json.dumps(client.describe_instances(), indent=2, default=str))
PY
```

### مثال على الأوامر المختصرة

```bash
awslocal ec2 describe-vpcs
awslocal ec2 describe-subnets
awslocal ec2 describe-instances
```

## 7. تطبيق Terraform

### داخل المجلد terraform

```bash
cd /workspaces/cloud-network-lab/terraform
terraform init
terraform validate
terraform plan
terraform apply -auto-approve
```

### التحقق من نجاح التكوين

إذا كانت النتيجة كالتالي:

```text
Success! The configuration is valid.
```

فهذا يعني أن تنسيق Terraform صحيح.

## 8. ملاحظات مهمة حول LocalStack

### دعم الخدمات
هذا المشروع تم تصميمه داخل LocalStack Pro، وقد تبين أن بعض الخدمات غير مدعومة في الترخيص الحالي إذا كانت غير مفعلة، مثل:

- ELBv2 / ALB
- RDS

لذلك تم تعليق هذه الموارد مؤقتًا حتى تتوفر الخدمة في البيئة أو عند استخدام ترخيص محدث.

### لماذا تم إلغاء ALB؟
لأن LocalStack الحالي يعرض خطأ مشابه لهذا:

```text
the elbv2 service is not included within your LocalStack license
```

### لماذا تم إلغاء RDS؟
لأن LocalStack الحالي يعرض خطأ مشابه لهذا:

```text
the rds service is not included within your LocalStack license
```

## 9. ملف .gitignore

تمت إضافة عناصر مهمة لتجنب رفع الملفات المحلية، مثل:

- `.env`
- `.localstack/`
- `.terraform/`
- `*.tfstate`
- `*.tfstate.*`

## 10. التحقق النهائي للمشروع

يمكن استخدام هذا الأمر كتحقق نهائي شامل:

```bash
cd /workspaces/cloud-network-lab && \
 echo '--- LocalStack health ---' && \
 curl -sS http://localhost:4566/_localstack/health && \
 echo && echo '--- EC2 VPCs ---' && \
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
print(json.dumps(client.describe_instances(), indent=2, default=str))
PY
&& \
 echo '--- Terraform validation ---' && \
 cd terraform && terraform fmt && terraform validate && terraform plan
```

## 11. التوثيق الإضافي

راجع [documentation/architecture.md](documentation/architecture.md) للحصول على وصف معماري أكثر تفصيلًا.

## 12. الخلاصة

هذا المشروع يمثل شبكة AWS صغيرة محاكاة داخل LocalStack، مع:

- VPC
- 3 Subnets
- Internet Gateway
- Route Tables
- Security Groups
- EC2 servers

وهو جاهز للتعلم، المحاكاة، والتحقق داخل البيئة المحلية قبل الانتقال إلى AWS الحقيقي أو إلى خدمة محمولة ذات دعم كامل.
