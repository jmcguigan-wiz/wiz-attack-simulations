variable "aws_region" {
  type    = string
  default = "us-east-1"
}
variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}
variable "wiz_api_client_id_ssm_parameter_name" {
  description = "The name of the WIZ Client ID parameter in SSM Parameter Store"
  type        = string
  default     = "/WIZ/WIZ-API-CLIENT-ID"
}
variable "wiz_api_client_secret_ssm_parameter_name" {
  description = "The name of the WIZ Client Secret parameter in SSM Parameter Store"
  type        = string
  default     = "/WIZ/WIZ_API_CLIENT_SECRET"
}
variable "wiz_api_client_id" {
  type      = string
  sensitive = true
}
variable "wiz_api_client_secret" {
  type      = string
  sensitive = true
}
variable "key_pair_name" {
  description = "Name of existing key pair to use. If empty, a new key pair will be created"
  type        = string
  default     = ""
}
variable "public_key" {
  description = "Public key material to use when creating a key pair. Only used if key_pair_name is empty"
  type        = string
  default     = ""
}