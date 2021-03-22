# Security Group para la Database (RDS).
resource "aws_security_group" "security_group_ddbb" {
  name   = var.resource_names.security_groups.ddbb
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = var.resource_names.security_groups.ddbb
  }
  depends_on = [
    aws_vpc.vpc
  ]
}

# Security Group para la Webapp (EC2).
resource "aws_security_group" "security_group_webapp" {
  name   = var.resource_names.security_groups.webapp
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = var.resource_names.security_groups.webapp
  }
  depends_on = [
    aws_vpc.vpc
  ]
}

# Security Group para el Load Balancer (ALB).
resource "aws_security_group" "security_group_balancer" {
  name   = var.resource_names.security_groups.balancer
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = var.resource_names.security_groups.balancer
  }
  depends_on = [
    aws_vpc.vpc
  ]
}

# Security Group para el Bastion Host (EC2).
resource "aws_security_group" "security_group_bastion" {
  name   = var.resource_names.security_groups.bastion
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = var.resource_names.security_groups.bastion
  }
  depends_on = [
    aws_vpc.vpc
  ]
}

# Habilitamos las peticiones entrantes Database (RDS) <- Webapp (EC2) en el puerto TCP 3306.
resource "aws_security_group_rule" "security_group_rule_1" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.security_group_webapp.id
  description              = "Webapp instances access"
  security_group_id        = aws_security_group.security_group_ddbb.id
  depends_on = [
    aws_security_group.security_group_webapp,
    aws_security_group.security_group_ddbb
  ]
}

# Habilitamos las peticiones salientes Webapp (EC2) -> Database (RDS) en el puerto TCP 3306.
resource "aws_security_group_rule" "security_group_rule_2" {
  type                     = "egress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.security_group_ddbb.id
  description              = "Webapp database access"
  security_group_id        = aws_security_group.security_group_webapp.id
  depends_on = [
    aws_security_group.security_group_webapp,
    aws_security_group.security_group_ddbb
  ]
}

# Habilitamos todo el tráfico saliente Webapp (EC2) -> Internet.
resource "aws_security_group_rule" "security_group_rule_3" {
  type      = "egress"
  from_port = 0
  to_port   = 0
  protocol  = "-1"
  cidr_blocks = [
    "0.0.0.0/0"
  ]
  description       = "Internet access"
  security_group_id = aws_security_group.security_group_webapp.id
  depends_on = [
    aws_security_group.security_group_webapp
  ]
}

# Habilitamos las peticiones entrantes Webapp (EC2) <- Load Balancer (ALB) en el puerto TCP 8080.
resource "aws_security_group_rule" "security_group_rule_4" {
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.security_group_balancer.id
  description              = "Webapp balancer access"
  security_group_id        = aws_security_group.security_group_webapp.id
  depends_on = [
    aws_security_group.security_group_webapp,
    aws_security_group.security_group_balancer
  ]
}

# Habilitamos las peticiones salientes Load Balancer (ALB) -> Webapp (EC2) en el puerto TCP 8080.
resource "aws_security_group_rule" "security_group_rule_5" {
  type                     = "egress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.security_group_webapp.id
  description              = "Webapp instances access"
  security_group_id        = aws_security_group.security_group_balancer.id
  depends_on = [
    aws_security_group.security_group_webapp,
    aws_security_group.security_group_balancer
  ]
}

# Habilitamos las peticiones entrantes Load Balancer (ALB) <- Internet en el puerto TCP 80.
resource "aws_security_group_rule" "security_group_rule_6" {
  type      = "ingress"
  from_port = 80
  to_port   = 80
  protocol  = "tcp"
  cidr_blocks = [
    "0.0.0.0/0"
  ]
  description       = "Webapp public access"
  security_group_id = aws_security_group.security_group_balancer.id
  depends_on = [
    aws_security_group.security_group_balancer
  ]
}

# Habilitamos las peticiones entrantes Bastion Host (EC2) <- Internet en el puerto TCP 3389.
resource "aws_security_group_rule" "security_group_rule_7" {
  type      = "ingress"
  from_port = 3389
  to_port   = 3389
  protocol  = "tcp"
  cidr_blocks = [
    "0.0.0.0/0"
  ]
  description       = "RDP public access"
  security_group_id = aws_security_group.security_group_bastion.id
  depends_on = [
    aws_security_group.security_group_bastion
  ]
}

# Habilitamos todo el tráfico saliente Bastion Host (EC2) -> Internet.
resource "aws_security_group_rule" "security_group_rule_8" {
  type      = "egress"
  from_port = 0
  to_port   = 0
  protocol  = "-1"
  cidr_blocks = [
    "0.0.0.0/0"
  ]
  description       = "Internet access"
  security_group_id = aws_security_group.security_group_bastion.id
  depends_on = [
    aws_security_group.security_group_bastion
  ]
}
