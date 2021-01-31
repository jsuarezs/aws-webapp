resource "aws_security_group" "ec2sg" {
  name        = "ec2sg"
  description = "Terraform SG for Web Servers"
  vpc_id      = aws_vpc.default.id
  # Internet traffic
  ingress {
    from_port = 8080
    to_port   = 8080
    protocol  = "tcp"
    #security_groups = aws_security_group.ec2sg.id
  }
  # Traffic to BBDD
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_launch_configuration" "websasg" {
  image_id        = "ami-0fc970315c2d38f01"
  instance_type   = "t2.micro"
  iam_instance_profile = "${aws_iam_instance_profile.test_instance_profile.id}"
  #security_groups = aws_security_group.ec2sg.id
  user_data       = <<-EOF
              #!/bin/bash
                sudo yum update -y
                sudo yum install -y docker
                sudo service docker start
                sudo docker run -d --name rtb -p 8080:8080 vermicida/rtb
              EOF
  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_autoscaling_group" "web" {
  name = "${aws_launch_configuration.websasg.name}-asg"

  min_size         = 1
  desired_capacity = 2
  max_size         = 4

  health_check_type = "EC2"
  target_group_arns = ["${aws_alb_target_group.group.arn}"]
  launch_configuration = aws_launch_configuration.websasg.id

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
  ]

  metrics_granularity = "1Minute"

  vpc_zone_identifier = aws_subnet.public.*.id

  # Required to redeploy without an outage.
  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "web"
    propagate_at_launch = true
  }
}
resource "aws_security_group" "alb" {
  name        = "terraform_alb_security_group"
  description = "Terraform load balancer security group"
  vpc_id      = aws_vpc.default.id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
  }

  # Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_alb" "alb" {
  name            = "alb"
  security_groups = [aws_security_group.alb.id]
  subnets         = aws_subnet.public.*.id
}
resource "aws_alb_target_group" "group" {
  name     = "alb-target"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.default.id
  stickiness {
    type = "lb_cookie"
  }
  # Alter the destination of the health check to be the login page.
  health_check {
    protocol            = "HTTP"
    path                = "/api/utils/healthcheck"
    port                = "traffic-port"
    matcher             = "200"
  }
}
resource "aws_alb_listener" "listener_http" {
  load_balancer_arn = aws_alb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.group.arn
    type             = "forward"
  }
}




