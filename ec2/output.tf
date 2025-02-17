# Output instance public IP
output "instance_public_ip" {
  value = aws_instance.wiz_instance.public_ip
}

# Output instance ID
output "instance_id" {
  value = aws_instance.wiz_instance.id
}

# Output IAM role name
output "iam_role_name" {
  value = aws_iam_role.wiz_ec2_role.name
}

# Output AMI ID being used
output "ami_id" {
  value = data.aws_ami.ubuntu.id
}

output "key_pair_name" {
  value = local.actual_key_pair_name
}

output "private_key" {
  value     = local.use_existing_key_pair ? null : tls_private_key.ssh[0].private_key_pem
  sensitive = true
}