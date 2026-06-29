resource "aws_ecs_cluster" "ecs-cluster" {
  name = "umami-cluster"

  tags = {
    Name = "umami-cluster"
  }
}

resource "aws_ecs_task_definition" "task-definition" {
  container_definitions = jsonencode([{
    
  }])
  family = aws_ecs_cluster.ecs-cluster.id
}

resource "aws_ecs_service" "ecs-ram-service" {
  name = "ck"
}

resource "aws_ecs_service" "ecs-cpu-service" {
  name = "ck"
}

resource "aws_iam_role_policy_attachment" "ecs-role-attachment" {
  role = "dce"
  policy_arn = "ded"
}

resource "aws_iam_role" "ecs-role" {
  assume_role_policy = "dew"
}

