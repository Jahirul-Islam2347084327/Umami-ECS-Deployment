
resource "aws_iam_role" "codedeploy" {
  name = "umami-codedeploy-service-role"


  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "codedeploy.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "umami-codedeploy-service-role"
  }
}

resource "aws_iam_role_policy_attachment" "codedeploy_ecs" {
  role       = aws_iam_role.codedeploy.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"
}


resource "aws_codedeploy_app" "app" {
  compute_platform = "ECS" 
  name             = "umami-deploy-app"
}


resource "aws_codedeploy_deployment_group" "app" {
  app_name               = aws_codedeploy_app.app.name
  deployment_group_name  = "umami-deployment-group"
  deployment_config_name = "CodeDeployDefault.ECSCanary10Percent5Minutes" 
  service_role_arn       = aws_iam_role.codedeploy.arn           


  ecs_service {
    cluster_name = var.cluster-name
    service_name = var.service-name
  }


  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT" 
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 5 
    }
  }

 
  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [var.alb-listener] 
      }

      target_group {
        name = var.target-blue-name
      }

      target_group {
        name = var.target-green-name
      }
    }
  }
}