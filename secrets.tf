resource "aws_secretsmanager_secret" "app_secret" {
  name = "demo-secret"
}

resource "aws_secretsmanager_secret_version" "secret_value" {
  secret_id = aws_secretsmanager_secret.app_secret.id

  secret_string = jsonencode({
    username = "admin"
    password = "mypassword123"
  })
}