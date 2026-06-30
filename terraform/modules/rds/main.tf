resource "aws_db_subnet_group" "main" {
  name = "umami-db-subnet-group"
  subnet_ids = var.private-subnet-ids 
  
  tags = {
  Name = "umami-db-subnet-group"
}
}

resource "aws_db_instance" "main" {
  identifier = "umami-db"
    engine = "postgres"
    engine_version = "16"
    instance_class = "db.t3.micro"
    allocated_storage = 20
    max_allocated_storage = 30

    db_name = "umami"
    username = jsondecode(aws_secretsmanager_secret_version.db-secret-val.secret_string)["username"]
    password = jsondecode(aws_secretsmanager_secret_version.db-secret-val.secret_string)["password"]

    db_subnet_group_name = aws_db_subnet_group.main.name
    vpc_security_group_ids = [var.rds-sg-id]
  

    skip_final_snapshot = true

    tags = {
        Name = "Umami-db"
    }
}

resource "aws_secretsmanager_secret" "db-secret" {
  name        = "umami-db-credentials"
  description = "Automatically managed master credentials for Umami RDS"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "db-secret-val" {
  secret_id = aws_secretsmanager_secret.db-secret.id
  secret_string = jsonencode({
    username = "umami_admin"                       
    password = random_password.db-password.result 
  })
}


resource "random_password" "db-password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}