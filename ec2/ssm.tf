resource "aws_ssm_parameter" "wiz_api_client_id_ssm_secret" {
  name  = var.wiz_api_client_id_ssm_parameter_name
  type  = "SecureString"
  value = var.wiz_api_client_id
}

resource "aws_ssm_parameter" "wiz_api_client_secret_ssm_secret" {
  name  = var.wiz_api_client_secret_ssm_parameter_name
  type  = "SecureString"
  value = var.wiz_api_client_secret
}