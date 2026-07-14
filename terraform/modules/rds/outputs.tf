output "rds-url" {
  sensitive   = true
  value = "postgresql://${jsondecode(aws_secretsmanager_secret_version.db-secret-val.secret_string)["username"]}:${jsondecode(aws_secretsmanager_secret_version.db-secret-val.secret_string)["password"]}@${aws_db_instance.main.endpoint}/${aws_db_instance.main.db_name}"
}

