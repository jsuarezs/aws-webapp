# Configuración del proveedor.
variable "config" {
  type = object({
    profile = string
    region  = string
  })
  default = {
    profile = "default"
    region  = "eu-west-1"
  }
}

# Nombres de los recursos.
variable "resource_names" {
  type = object({
    vpc               = string
    eip               = string
    natgw             = string
    igw               = string
    route_tables      = map(string)
    subnets           = map(string)
    security_groups   = map(string)
    subnet_group      = string
    rds_instance      = string
    secret            = string
    policy            = string
    role              = string
    profile           = string
    key_pair          = string
    template          = string
    autoscaling_group = string
    bastion           = string
    target_group      = string
    load_balancer     = string
  })
  default = {
    vpc   = "kc-aws-test-vpc"
    eip   = "kc-aws-test-nat-gw-eip"
    natgw = "kc-aws-test-nat-gw"
    igw   = "kc-aws-test-igw"
    route_tables = {
      private = "kc-aws-test-private-rt"
      public  = "kc-aws-test-public-rt"
    }
    subnets = {
      private_a = "kc-aws-test-private-subnet-a"
      private_b = "kc-aws-test-private-subnet-b"
      public_a  = "kc-aws-test-public-subnet-a"
      public_b  = "kc-aws-test-public-subnet-b"
    }
    security_groups = {
      webapp   = "kc-aws-test-webapp-sg"
      ddbb     = "kc-aws-test-ddbb-sg"
      balancer = "kc-aws-test-balancer-sg"
      bastion  = "kc-aws-test-bastion-sg"
    }
    subnet_group      = "kc-aws-test-mysql-sg"
    rds_instance      = "kc-aws-test-mysql-rds"
    secret            = "rtb-db-secret"
    policy            = "kc-aws-test-rtb-sm-policy"
    role              = "kc-aws-test-ec2-role"
    profile           = "kc-aws-test-ec2-profile"
    key_pair          = "mykey"
    template          = "kc-aws-test-webapp-vm"
    autoscaling_group = "kc-aws-test-webapp-asg"
    bastion           = "kc-aws-test-bastion"
    target_group      = "kc-aws-test-webapp-tg"
    load_balancer     = "kc-aws-test-webapp-alb"
  }
}

# Configuración de la base de datos.
variable "database" {
  type = object({
    dbname   = string
    username = string
    password = string
  })
  default = {
    dbname   = "remember_the_bread"
    username = "rtb_user"
    password = "rtb-pass-1$"
  }
}