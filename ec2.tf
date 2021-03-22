
# Creamos el perfil necesario para asignar el rol previamente creado a las instancias.
resource "aws_iam_instance_profile" "ec2_profile" {
  name = var.resource_names.profile
  role = aws_iam_role.db_conn_role.id
  depends_on = [
    aws_iam_policy_attachment.db_conn_policy_role_assoc
  ]
}

# Creamos un KeyPair a partir de la clave pública de nuestro certificado local.
resource "aws_key_pair" "key_pair" {
  key_name   = var.resource_names.key_pair
  public_key = file("./${var.resource_names.key_pair}.pub")
}

# Creamos la plantilla con la configuración de las instancias EC2.
resource "aws_launch_template" "webapp_vm" {
  name                    = var.resource_names.template
  image_id                = "ami-06ce3edf0cff21f07"
  instance_type           = "t2.micro"
  key_name                = aws_key_pair.key_pair.key_name
  disable_api_termination = false
  user_data               = filebase64("./boot.sh")
  network_interfaces {
    associate_public_ip_address = false
    security_groups = [
      aws_security_group.security_group_webapp.id
    ]
  }
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }
  tags = {
    Name = var.resource_names.template
  }
  depends_on = [
    aws_security_group.security_group_webapp,
    aws_iam_instance_profile.ec2_profile,
    aws_key_pair.key_pair
  ]
}

# Creamos el grupo de auto escalado.
resource "aws_autoscaling_group" "webapp_asg" {
  desired_capacity = 2
  max_size         = 2
  min_size         = 2
  vpc_zone_identifier = [
    aws_subnet.private_subnet_a.id,
    aws_subnet.private_subnet_b.id
  ]
  launch_template {
    id      = aws_launch_template.webapp_vm.id
    version = "$Latest"
  }
  target_group_arns = [
    aws_lb_target_group.webapp_tg.arn
  ]
  tag {
    key                 = "Name"
    value               = var.resource_names.autoscaling_group
    propagate_at_launch = true
  }
  depends_on = [
    aws_subnet.private_subnet_a,
    aws_subnet.private_subnet_b,
    aws_launch_template.webapp_vm,
    aws_lb_target_group.webapp_tg
  ]
}

# Balanceador que expone la Webapp públicamente.
resource "aws_lb" "webapp_alb" {
  name               = var.resource_names.load_balancer
  internal           = false
  load_balancer_type = "application"
  security_groups = [
    aws_security_group.security_group_balancer.id
  ]
  subnets = [
    aws_subnet.public_subnet_a.id,
    aws_subnet.public_subnet_b.id
  ]
  depends_on = [
    aws_subnet.public_subnet_a,
    aws_subnet.public_subnet_b,
    aws_security_group.security_group_balancer
  ]
}

# Target Group para configurar la Webapp como destino del tráfico entrante del balanceador.
resource "aws_lb_target_group" "webapp_tg" {
  name        = var.resource_names.target_group
  target_type = "instance"
  protocol    = "HTTP"
  port        = 8080
  vpc_id      = aws_vpc.vpc.id
  health_check {
    protocol            = "HTTP"
    path                = "/api/utils/healthcheck"
    port                = "traffic-port"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 4
    interval            = 5
    matcher             = "200"
  }
  depends_on = [
    aws_lb.webapp_alb
  ]
}

# Listener para redirigir el tráfico Internet -> Webapp.
resource "aws_lb_listener" "webapp_alb_listener" {
  load_balancer_arn = aws_lb.webapp_alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.webapp_tg.arn
  }
  depends_on = [
    aws_lb.webapp_alb,
    aws_lb_target_group.webapp_tg
  ]
}

#Bastion host to check webapp

# Creamos la instancia en EC2.
resource "aws_instance" "bastion" {
  ami                         = "ami-0c95efaa8fa6e2424"
  instance_type               = "t2.large"
  subnet_id                   = aws_subnet.public_subnet_a.id
  associate_public_ip_address = true
  key_name                    = aws_key_pair.key_pair.key_name
  vpc_security_group_ids = [
    aws_security_group.security_group_bastion.id
  ]
  disable_api_termination = false
  monitoring              = false
  tags = {
    Name = var.resource_names.bastion
  }
  depends_on = [
    aws_subnet.public_subnet_a,
    aws_security_group.security_group_bastion,
    aws_key_pair.key_pair
  ]
}
