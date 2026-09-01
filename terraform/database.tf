# RDS is intentionally disabled for this LocalStack environment.
# The current LocalStack license does not include the `rds` service,
# so creating aws_db_subnet_group and aws_db_instance would fail at apply time.
# Keep the example below only as reference for an upgraded LocalStack license or AWS real account.

# resource "aws_db_subnet_group" "main" {
#   name       = "cloud-lab-db-subnet-group"
#   subnet_ids = [aws_subnet.database.id, aws_subnet.private.id]
#
#   tags = {
#     Name = "cloud-lab-db-subnet-group"
#   }
# }
#
# resource "aws_db_instance" "rds" {
#   allocated_storage      = 20
#   engine                 = "mysql"
#   engine_version         = "8.0"
#   instance_class         = "db.t3.micro"
#   db_name                = "appdb"
#   username               = "admin"
#   password               = "Password123!"
#   db_subnet_group_name   = aws_db_subnet_group.main.name
#   vpc_security_group_ids = [aws_security_group.db_sg.id]
#   skip_final_snapshot    = true
#
#   tags = {
#     Name = "cloud-lab-rds-db"
#   }
# }
