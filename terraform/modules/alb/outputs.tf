output "alb-dns" {
  value = aws_lb.main.dns_name
}

output "target-group-arn" {
  value = aws_lb_target_group.app.arn
}

output "alb-arn" {
  
  value       = aws_lb.main.arn
}

output "alb-zone-id" {
  
  value       = aws_lb.main.zone_id
}