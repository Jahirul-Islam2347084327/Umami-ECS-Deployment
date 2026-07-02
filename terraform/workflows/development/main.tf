terraform {
  backend "s3" {
    bucket = "jahis-devops-directive-state-2026"
    key = "tf-infra/terraform.tfstate"
    region = "us-east-1"
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
  region = "us-east-1"
}

/*==============================================================================
  UNCOMMENT THIS TO CREATE THE BACKEND THEN LATER COMMENT IT TO AVOID DESTROYING
  ==============================================================================
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
*/
module "vpc" {
  source = "../../modules/network"
  az1 = var.az1
  az2 = var.az2
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
}

module "alb" {
  source = "../../modules/alb"
  alb-security-group-id = module.security.alb-security
  certificate-arn = 
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