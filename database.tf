resource "aws_db_instance" "project-1" {
  allocated_storage                   = 20
  identifier                          = "mysql-db-01"
  engine                              = "mysql"
  engine_version                      = "5.7"
  instance_class                      = "db.t2.micro"
  name                                = "db_name"
  username                            = "admin"
  password                            = "password"
  port                                = "3306"
  iam_database_authentication_enabled = true
  #vpc_security_group_ids = aws_security_group.SecurityGroupDB.id
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
}
resource "aws_ssm_parameter" "secret1" {
  name        = "/main/password"
  description = "The parameter description"
  type        = "SecureString"
  value       = var.database_master_password 
}
resource "aws_ssm_parameter" "user" {
  name  = "/main/username"
  type  = "String"
  value = "admin"
}
resource "aws_ssm_parameter" "database" {
  name  = "/main/database"
  type  = "String"
  value = "mysql-db-01"
}
resource "aws_ssm_parameter" "endpoint" {
  name  = "/main/endpoint"
  type  = "String"
  value = ""
}
resource "aws_db_subnet_group" "db-group1" {
  name       = "db-group1"
  subnet_ids = [aws_subnet.private_subnet1a.id, aws_subnet.private_subnet1b.id]

  tags = {
    Name = "My DB subnet group1"
  }
  
}

resource "aws_db_instance" "project-2" {
  allocated_storage                   = 20
  identifier                          = "mysql-db-02"
  engine                              = "mysql"
  engine_version                      = "5.7"
  instance_class                      = "db.t2.micro"
  name                                = "db_name"
  username                            = "admin"
  password                            = "password"
  port                                = "3306"
  iam_database_authentication_enabled = true
  #security_groups = [aws_security_group.SecurityGroupDB.id]
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
}
resource "aws_db_subnet_group" "db-group2" {
  name       = "db-group2"
  subnet_ids = [aws_subnet.private_subnet2a.id, aws_subnet.private_subnet2b.id]

  tags = {
    Name = "My DB subnet group2"
  }
}
# Create Security Group for Database
# terraform aws create security group
resource "aws_security_group" "SecurityGroupDB" {
  name        = "Database Security Group"
  description = "Enable MySQL on Port 3306"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "MySQL Access"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.webserver-security-group2.id]
  }
  ingress {
    description     = "MySQL Access"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.elb_http.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "SecurityGroupDB Security Group"
  }
}