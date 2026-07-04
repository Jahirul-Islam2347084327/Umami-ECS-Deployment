output "cluster-name" {
  value = aws_ecs_cluster.ecs-cluster.name
}

output "service-name" {
  value = aws_ecs_service.app.name
}