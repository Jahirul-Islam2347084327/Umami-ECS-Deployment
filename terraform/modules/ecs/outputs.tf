output "cluster-name" {
  value = aws_ecs_cluster.ecs-cluster.name
}

output "service-name" {
  value = aws_ecs_service.app.name
}

output "ecs-task-definition-arn" {
  value = aws_ecs_task_definition.task-definition.arn
}