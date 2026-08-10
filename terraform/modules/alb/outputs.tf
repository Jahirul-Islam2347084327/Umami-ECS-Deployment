output "alb-dns" {
  value = aws_lb.main.dns_name
}

output "target-group-arn" {
  value = aws_lb_target_group.blue.arn
}

output "alb-arn" {
  
  value = aws_lb.main.arn
}

output "alb-zone-id" {
  
  value = aws_lb.main.zone_id
}

output "target-blue-name" {
  value = aws_lb_target_group.blue.name
}

output "target-green-name" {
  value = aws_lb_target_group.green.name
}

output "alb-listener" {
  value = aws_lb_listener.https.arn
}