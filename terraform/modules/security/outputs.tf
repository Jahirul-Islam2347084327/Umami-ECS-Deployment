output "ecs-security" {
  value = [aws_security_group.ecs-security.id]
  }

output "alb-security" {
  value = aws_security_group.alb-security.id
}

output "rds-security" {
  value = aws_security_group.rds-security.id
}

output "endpoint-security" {
  value = aws_security_group.vpc_endpoint_sg.id
}