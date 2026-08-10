resource "aws_lb" "main" {
  name = "umami-lb"
  load_balancer_type = "application"
  security_groups = [var.alb-security-group-id]
  subnets = var.public-subnets-id
tags = {
  Name = "umami-lb"
}
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.main.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.certificate-arn

  default_action {
    type = "forward"

    forward {
      target_group {
        arn    = aws_lb_target_group.blue.arn
        weight = 100
      }

      target_group {
        arn    = aws_lb_target_group.green.arn
        weight = 0
      }

    }
  }

  tags = {
    Name = "umami-listener-https"
  }

  lifecycle {
    ignore_changes = [default_action]
  }
}


resource "aws_lb_target_group" "blue" {
   name = "umami-blue-tg"
  port = 3000
  protocol = "HTTP"
  vpc_id = var.vpc-id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/api/heartbeat"
    protocol            = "HTTP"
    matcher             = "200"
  }
    deregistration_delay = 30

    tags = {
        Name = "umami-blue-tg"
    }
}

resource "aws_lb_target_group" "green" {
   name = "umami-green-tg"
  port = 3000
  protocol = "HTTP"
  vpc_id = var.vpc-id
  target_type = "ip"


  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/api/heartbeat"
    protocol            = "HTTP"
    matcher             = "200"
  }
    deregistration_delay = 30

    tags = {
        Name = "umami-green-tg"
    }
  
}