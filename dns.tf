resource "aws_route53_record" "terraform" {
  zone_id = aws_route53_zone.zone.zone_id
  name    = "aws.kcdevops.com"
  type    = "A"
  alias {
    name                   = aws_alb.alb.dns_name
    zone_id                = aws_alb.alb.zone_id
    evaluate_target_health = true
  }
}
resource "aws_route53_zone" "zone" {
  name = "kcdevops.com"
  vpc {
    vpc_id = aws_vpc.default.id
  }
}