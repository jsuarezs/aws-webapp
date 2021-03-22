
# VPC.
resource "aws_vpc" "vpc" {
  cidr_block                       = "10.0.0.0/16"
  instance_tenancy                 = "default"
  assign_generated_ipv6_cidr_block = false
  enable_dns_hostnames             = true
  enable_dns_support               = true
  tags = {
    Name = var.resource_names.vpc
  }
}

# Subnet pública A en zona eu-west-1a.
resource "aws_subnet" "public_subnet_a" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "eu-west-1a"
  map_public_ip_on_launch = false
  tags = {
    Name = var.resource_names.subnets.public_a
  }
  depends_on = [
    aws_vpc.vpc
  ]
}

# Subnet pública B en zona eu-west-1b.
resource "aws_subnet" "public_subnet_b" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = "eu-west-1b"
  map_public_ip_on_launch = false
  tags = {
    Name = var.resource_names.subnets.public_b
  }
  depends_on = [
    aws_vpc.vpc
  ]
}

# Internet Gateway para habilitar el tráfico Zona pública <-> Internet.
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = var.resource_names.igw
  }
  depends_on = [
    aws_vpc.vpc
  ]
}

# Route Table para enrutar el tráfico en la zona pública.
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = var.resource_names.route_tables.public
  }
  depends_on = [
    aws_vpc.vpc,
    aws_internet_gateway.igw
  ]
}

# Asociamos la Subnet pública A a la Route Table.
resource "aws_route_table_association" "public_route_table_associations_1" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.public_route_table.id
  depends_on = [
    aws_subnet.public_subnet_a,
    aws_route_table.public_route_table
  ]
}

# Asociamos la Subnet pública B a la Route Table.
resource "aws_route_table_association" "public_route_table_associations_2" {
  subnet_id      = aws_subnet.public_subnet_b.id
  route_table_id = aws_route_table.public_route_table.id
  depends_on = [
    aws_subnet.public_subnet_b,
    aws_route_table.public_route_table
  ]
}

# Elastic IP, necesaria para el NAT Gateway.
resource "aws_eip" "natgw_eip" {
  vpc              = true
  public_ipv4_pool = "amazon"
  tags = {
    Name = var.resource_names.eip
  }
  depends_on = [
    aws_vpc.vpc
  ]
}

# NAT Gateway para habilitar el tráfico Zona privada -> Internet.
resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.natgw_eip.id
  subnet_id     = aws_subnet.public_subnet_a.id
  tags = {
    Name = var.resource_names.natgw
  }
  depends_on = [
    aws_vpc.vpc,
    aws_subnet.public_subnet_a,
    aws_eip.natgw_eip
  ]
}

# Subnet privada A en zona eu-west-1a.
resource "aws_subnet" "private_subnet_a" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-west-1a"
  map_public_ip_on_launch = false
  tags = {
    Name = var.resource_names.subnets.private_a
  }
  depends_on = [
    aws_vpc.vpc
  ]
}

# Subnet privada B en zona eu-west-1b.
resource "aws_subnet" "private_subnet_b" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "eu-west-1b"
  map_public_ip_on_launch = false
  tags = {
    Name = var.resource_names.subnets.private_b
  }
  depends_on = [
    aws_vpc.vpc
  ]
}

# Route Table para enrutar el tráfico en la zona privada.
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.natgw.id
  }
  tags = {
    Name = var.resource_names.route_tables.private
  }
  depends_on = [
    aws_vpc.vpc,
    aws_nat_gateway.natgw
  ]
}

# Asociamos la Subnet privada A a la Route Table.
resource "aws_route_table_association" "private_route_table_associations_1" {
  subnet_id      = aws_subnet.private_subnet_a.id
  route_table_id = aws_route_table.private_route_table.id
  depends_on = [
    aws_subnet.private_subnet_a,
    aws_route_table.private_route_table
  ]
}

# Asociamos la Subnet privada B a la Route Table.
resource "aws_route_table_association" "private_route_table_associations_2" {
  subnet_id      = aws_subnet.private_subnet_b.id
  route_table_id = aws_route_table.private_route_table.id
  depends_on = [
    aws_subnet.private_subnet_b,
    aws_route_table.private_route_table
  ]
}