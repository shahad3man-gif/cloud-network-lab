# 1. استخدام AMI ثابت متوافق مع LocalStack
# يتم استخدام قيمة mock AMI لأن LocalStack لا يحتوي على صور Ubuntu الحقيقية من AWS.

# 2. إنشاء سيرفر الويب (Web Server) في الشبكة العامة
resource "aws_instance" "web_server" {
  ami           = "ami-12345678"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public.id

  vpc_security_group_ids = [aws_security_group.web_sg.id]

  # سكربت بسيط يعمل تلقائياً عند تشغيل السيرفر لتثبيت Nginx
  user_data = <<-EOF
              #!/bin/bash
              echo "Hello from Web Server" > index.html
              python3 -m http.server 80 &
              EOF

  tags = {
    Name = "cloud-lab-web-server"
  }
}

# 3. إنشاء سيرفر التطبيق (App Server) في الشبكة الخاصة
resource "aws_instance" "app_server" {
  ami           = "ami-12345678"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private.id

  vpc_security_group_ids = [aws_security_group.app_sg.id]

  tags = {
    Name = "cloud-lab-app-server"
  }
}
