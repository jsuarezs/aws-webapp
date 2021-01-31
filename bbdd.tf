# Database 

resource "aws_security_group" "default" {
  name        = "rds_security_group"
  description = "Terraform SG for RDS MySQL server"
  vpc_id      = aws_vpc.default.id
  # Keep traffic private
  ingress {
    from_port = 3306
    to_port   = 3306
    protocol  = "tcp"
    #security_groups = aws_security_group.default.id
  }
  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_db_subnet_group" "default" {
  name       = "main"
  subnet_ids = aws_subnet.private.*.id

  tags = {
    Name = "My DB subnet group"
  }
}
resource "aws_db_instance" "default" {
  identifier           = "webapp-mysql"
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t2.micro"
  name                 = "webappdb"
  username             = "javier"
  password             = "javier00"
  db_subnet_group_name = aws_db_subnet_group.default.id
  skip_final_snapshot = true
  #vpc_security_groups    = aws_security_group.default.id
}
resource "aws_secretsmanager_secret" "default" {
  name        = "rtb-db-secret"
  description = "BBDD secret"
}
resource "aws_secretsmanager_secret_version" "default" {
  secret_id     = aws_secretsmanager_secret.default.id
  secret_string = "{\"username\":\"javier\":\"password\":\"javier00\",\"host\":\"aws_db_instance.default.address\":\"db\":\"webappdb\"}"
}
