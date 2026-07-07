resource "aws_ecs_cluster" "ecs-cluster" {
  name = "umami-cluster"

  tags = {
    Name = "umami-cluster"
  }
}

resource "aws_iam_role_policy_attachment" "ecs_execution" {
  role = aws_iam_role.ecs_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_cloudwatch_log_group" "ecs" {
 name = "ecs-umami"
 retention_in_days = 7
 tags = {
  Name = "ecs-cloudwatch-logs"
 } 
}

resource "aws_iam_role" "ecs_execution" {
    name = "ecs-execution-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principal = {
                Service = "ecs-tasks.amazonaws.com"
            }
        }]
    })
}

resource "aws_ecs_task_definition" "task-definition" {

  requires_compatibilities = ["FARGATE"]
  network_mode = "awsvpc"
  cpu = "512"
  memory = "1024"
  family = "umami-task"
  execution_role_arn = aws_iam_role.ecs_execution.arn
  container_definitions = jsonencode ([{

    name = "umami"
    image = var.image-url 
    

    portMappings = [{
        containerPort = 3000
        protocol = "tcp"
    }]
    logConfiguration = {
        logDriver = "awslogs"
        options = {
            "awslogs-group" = aws_cloudwatch_log_group.ecs.name
            "awslogs-region" = var.region
            "awslogs-stream-prefix" = "ecs"
        }
    }
    secrets = [
        {
          name      = "APP_SECRET"
          valueFrom = aws_ssm_parameter.app_secret.arn
        },
        {
        name = "DATABASE_URL"
        valueFrom = aws_ssm_parameter.db_url.arn
        }
      ]
  }]) 
}

resource "aws_ecs_service" "app" {
    name = "umami-service"
    cluster = aws_ecs_cluster.ecs-cluster.id
    task_definition = aws_ecs_task_definition.task-definition.arn
    desired_count = 2
    launch_type = "FARGATE" 

    network_configuration {
      subnets = var.private-subnet-ids #subnet ids
      security_groups = var.ecs-security-group-id #securtiy group id
      assign_public_ip = false
    }

    load_balancer {
    target_group_arn = var.target-group-arn #target group arn
    container_name   = "umami"
    container_port   = 3000
    }
  deployment_controller {
    type = "CODE_DEPLOY"
  }

  lifecycle {
    ignore_changes = [
      load_balancer,   
      task_definition  
    ]
  }

  tags = {
    Name = "umami-service"
  }
}


resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 5        # Maximum number of containers allowed
  min_capacity       = 2       # Minimum number of containers allowed
  resource_id        = "service/${aws_ecs_cluster.ecs-cluster.name}/${aws_ecs_service.app.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}


resource "aws_appautoscaling_policy" "ecs_policy_cpu" {
  name               = "cpu-autoscaling-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = 70.0  # Scale up if average CPU utilization crosses 70%
    scale_in_cooldown  = 300   # Wait 5 mins 
    scale_out_cooldown = 60    # Scales out quickly if traffic spikes
  }
}

resource "aws_appautoscaling_policy" "ecs_policy_memory" {
  name               = "memory-autoscaling-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
    target_value       = 70.0  # Scale up if average RAM crosses 70%
    scale_in_cooldown  = 300
    scale_out_cooldown = 60
  }
}


resource "random_password" "app_secret" {
  length  = 32
  special = false
}


resource "aws_ssm_parameter" "app_secret" {
  name        = "/umami/APP_SECRET"
  type        = "SecureString"
  value       = random_password.app_secret.result
  description = "Encryption secret key for Umami analytics application sessions"
}


resource "aws_iam_policy" "ecs_ssm_read" {
  name        = "umami-ecs-ssm-read-policy"
  description = "Allows ECS Task Execution Role to fetch values from Parameter Store"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameters",
          "kms:Decrypt"
        ]
        
        Resource = [
          aws_ssm_parameter.app_secret.arn,
          aws_ssm_parameter.db_url.arn
        ]
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "ecs_execution_ssm" {
  role       = aws_iam_role.ecs_execution.name
  policy_arn = aws_iam_policy.ecs_ssm_read.arn
}

resource "aws_ssm_parameter" "db_url" {
  name  = "/umami/DATABASE_URL"
  type  = "SecureString"
  value = var.database-url
}

