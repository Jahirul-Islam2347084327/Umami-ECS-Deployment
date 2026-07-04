terraform {
  backend "s3" {
    bucket = "jahis-devops-directive-state-2026"
    key = "tf-infra/terraform.tfstate"
    region = "us-east-1" # change this to your desired region
    dynamodb_table = "terraform-state-locking"
    encrypt = true
  }
    required_providers {
      aws = {
        source = "hashicorp/aws"
        version = "~> 6.0"
      }
    }
}

provider "aws" {
  region = var.region
}

resource "aws_s3_bucket" "terraform_state" { 
  bucket = "jahis-devops-directive-state-2026"
  force_destroy = true
  versioning {
    enabled = true
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_dynamodb_table" "terraform-locks" {
  name = "terraform-state-locking"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}

module "vpc" {
  source = "../../modules/network"
  az1 = var.az1
  az2 = var.az2
  region = var.region
}

module "ecr" {
  source = "../../modules/ecr"
}

module "ecs" {
  source = "../../modules/ecs"
  target-group-arn = module.alb.target-group-arn
  ecs-security-group-id = module.security.ecs-security
  database-url = module.rds.rds-url
  image-url = module.ecr.ecr-repo-url
  private-subnet-ids = module.vpc.private-subnet-ids
  region = var.region
}

module "alb" {
  source = "../../modules/alb"
  alb-security-group-id = module.security.alb-security
  certificate-arn = module.route53.acm-arn
  public-subnets-id = module.vpc.public-subnet-ids
  vpc-id = module.vpc.vpc-id
}

module "rds" {
  source = "../../modules/rds"
  private-subnet-ids = module.vpc.private-subnet-ids
  rds-sg-id = module.security.rds-security
}

module "security" {
  source = "../../modules/security"
  vpc-id = module.vpc.vpc-id
}

module "route53" {
  source = "../../modules/route53"
  alb-dns-name = module.alb.alb-dns
  alb-zone-id = module.alb.alb-zone-id
  custom-url =  var.custom-url
}

module "waf" {
  source = "../../modules/waf"
  alb-arn = module.alb.alb-arn
}

module "codedeploy" {
  source = "../../modules/codedeploy"
  target-blue-name = module.alb.target-blue-name
  target-green-name = module.alb.target-green-name
  alb-listener = module.alb.alb-listener
  service-name = module.ecs.service-name
  cluster-name = module.ecs.cluster-name
}