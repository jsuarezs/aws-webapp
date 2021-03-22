# Creamos el dominio kcdevops.com como Hosted Zone privada.
resource "aws_route53_zone" "kcdevops" {
  name = "kcdevops.com"
  vpc {
    vpc_id = aws_vpc.vpc.id
  }
}

# Record A para asociar el subdominio aws.kcdevops.com al DNS del Load Balancer.
resource "aws_route53_record" "aws" {
  zone_id = aws_route53_zone.kcdevops.zone_id
  name    = "aws.kcdevops.com"
  type    = "A"
  alias {
    name                   = aws_lb.webapp_alb.dns_name
    zone_id                = aws_lb.webapp_alb.zone_id
    evaluate_target_health = true
  }
  depends_on = [
    aws_route53_zone.kcdevops,
    aws_lb.webapp_alb
  ]
}