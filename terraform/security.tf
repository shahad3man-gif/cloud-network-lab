# 1. جدار ناري لطبقة الويب (Web Security Group)
resource "aws_security_group" "web_sg" {
  name        = "web-server-sg"
  description = "Allow HTTP, HTTPS, and SSH traffic"
  vpc_id      = aws_vpc.main.id

  # السماح بمرور حركة الويب HTTP من أي مكان
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # السماح بمرور حركة الويب المشفرة HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # السماح لاتصال SSH للتحكم
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # السماح بجميع الخروج من السيرفر (Outbound)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-sg"
  }
}

# 2. جدار ناري لطبقة التطبيقات (App Security Group)
resource "aws_security_group" "app_sg" {
  name        = "app-server-sg"
  description = "Allow traffic only from Web SG"
  vpc_id      = aws_vpc.main.id

  # قبول اتصالات التطبيق فقط إذا كانت قادمة من الـ Web SG
  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "app-sg"
  }
}

# 3. جدار ناري لقواعد البيانات (Database Security Group)
resource "aws_security_group" "db_sg" {
  name        = "database-sg"
  description = "Allow DB traffic only from App SG"
  vpc_id      = aws_vpc.main.id

  # قبول الاتصال بقاعدة البيانات (MySQL 3306) فقط من الـ App SG
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "database-sg"
  }
}
