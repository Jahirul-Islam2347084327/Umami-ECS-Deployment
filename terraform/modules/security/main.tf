resource "aws_security_group" "alb-security" {
  name = "alb-security"
  vpc_id = var.vpc-id

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

egress {
    from_port = 0
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
    protocol = "-1"
}

  tags = {
    Name ="alb-security"
  }
}

resource "aws_security_group" "ecs-security" {
  name = "ecs-security"
  vpc_id = var.vpc-id

  ingress {
    from_port = 3000
    to_port = 3000
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_groups = [aws_security_group.alb-security.id]
  }
  
egress {
    from_port = 0
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
    protocol = "-1"
}
  tags = {
    Name ="ecs-security"
  }
}

resource "aws_security_group" "rds-security" {
  name = "rds-security"
  vpc_id = var.vpc-id

  ingress {
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_groups = [aws_security_group.ecs-security.id]
  }
    ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_groups = [aws_security_group.ecs-security.id]
  }
  
egress {
    from_port = 0
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
    protocol = "-1"
}
  tags = {
    Name ="rds-security"
  }
}