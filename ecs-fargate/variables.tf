variable "aws_region" {
  type    = string
  default = "us-east-1"
}
variable "ecs_cluster_name" {
  type    = string
  default = "wiz-cluster"
}
variable "sensor_pullkey_username" {
  type = string
}
variable "sensor_pullkey_password" {
  type = string
}
variable "wiz_api_client_id" {
  type = string
}
variable "wiz_api_client_secret" {
  type = string
}
variable "wiz_fargate_attack_scenario_command" {
  type = string
}