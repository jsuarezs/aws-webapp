# Subnet Group.
resource "aws_db_subnet_group" "rds_subnet_group" {
  name        = var.resource_names.subnet_group
  description = "Webapp database subnet group"
  subnet_ids = [
    aws_subnet.private_subnet_a.id,
    aws_subnet.private_subnet_b.id
  ]
  tags = {
    Name = var.resource_names.subnet_group
  }
  depends_on = [
    aws_subnet.private_subnet_a,
    aws_subnet.private_subnet_b
  ]
}

# Instancia MySQL de base de datos.
resource "aws_db_instance" "rds_instance" {
  engine                              = "MySQL"
  engine_version                      = "8.0.17"
  identifier                          = var.resource_names.rds_instance
  port                                = 3306
  name                                = var.database.dbname
  username                            = var.database.username
  password                            = var.database.password
  iam_database_authentication_enabled = false
  instance_class                      = "db.t2.micro"
  allocated_storage                   = 20
  storage_type                        = "gp2"
  storage_encrypted                   = false
  max_allocated_storage               = 0
  db_subnet_group_name                = aws_db_subnet_group.rds_subnet_group.name
  publicly_accessible                 = true
  vpc_security_group_ids = [
    aws_security_group.security_group_ddbb.id
  ]
  apply_immediately            = true
  multi_az                     = false
  allow_major_version_upgrade  = false
  auto_minor_version_upgrade   = false
  deletion_protection          = false
  skip_final_snapshot          = true
  performance_insights_enabled = false
  backup_retention_period      = 0
  depends_on = [
    aws_db_subnet_group.rds_subnet_group
  ]
}

# Secreto en Secrets Manager.
resource "aws_secretsmanager_secret" "db_conn_secret" {
  name        = var.resource_names.secret
  description = "Webapp database connection secret"
  tags = {
    Name = var.resource_names.secret
  }
  depends_on = [
    aws_db_instance.rds_instance
  ]
}

# Almacenamos las credenciales de conexión en el secreto creado anteriormente.
resource "aws_secretsmanager_secret_version" "db_conn_secret_value" {
  secret_id = aws_secretsmanager_secret.db_conn_secret.id
  secret_string = jsonencode({
    "host" : aws_db_instance.rds_instance.address,
    "db" : var.database.dbname,
    "username" : var.database.username,
    "password" : var.database.password
  })
  depends_on = [
    aws_secretsmanager_secret.db_conn_secret
  ]
}
