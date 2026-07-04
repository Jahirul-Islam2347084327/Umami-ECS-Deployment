resource "random_password" "app_secret" {
  length  = 32
  special = false
}


resource "aws_ssm_parameter" "app_secret" {
  name        = "/umami/prod/APP_SECRET"
  type        = "SecureString"
  value       = random_password.app_secret.result
  description = "Encryption secret key for Umami analytics application sessions"
}

resource "aws_ssm_parameter" "db_url" {
  name        = "/umami/prod/DATABASE_URL"
  type        = "SecureString"
  value       = var.database-url
  description = "Production RDS connection string for Umami"
}