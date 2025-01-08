resource "aws_secretsmanager_secret" "wiz_registry_credentials" {
  name                    = "wiz-registry-credentials-test"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "wiz_registry_credentials_version" {
  secret_id = aws_secretsmanager_secret.wiz_registry_credentials.id
  secret_string = jsonencode({
    username = var.sensor_pullkey_username
    password = var.sensor_pullkey_password
  })
}

resource "aws_secretsmanager_secret" "wiz_sensor_service_account" {
  name                    = "wiz-sensor-service-account-test"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "wiz_sensor_service_account_version" {
  secret_id = aws_secretsmanager_secret.wiz_sensor_service_account.id
  secret_string = jsonencode({
    WIZ_API_CLIENT_ID     = var.wiz_api_client_id
    WIZ_API_CLIENT_SECRET = var.wiz_api_client_secret
  })
}