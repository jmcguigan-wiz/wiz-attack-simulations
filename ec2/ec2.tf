# Query latest Ubuntu AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical's AWS account ID

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

# Key Pair handling
locals {
  use_existing_key_pair = var.key_pair_name != ""
  actual_key_pair_name  = local.use_existing_key_pair ? var.key_pair_name : "generated-key-pair-${random_id.suffix.hex}"
}

resource "random_id" "suffix" {
  byte_length = 4
}

resource "tls_private_key" "ssh" {
  count     = local.use_existing_key_pair ? 0 : 1
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated" {
  count      = local.use_existing_key_pair ? 0 : 1
  key_name   = local.actual_key_pair_name
  public_key = var.public_key != "" ? var.public_key : tls_private_key.ssh[0].public_key_openssh
}

# Create EC2 instance
resource "aws_instance" "wiz_instance" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  iam_instance_profile   = aws_iam_instance_profile.wiz_ec2_profile.name
  key_name               = local.actual_key_pair_name
  user_data              = <<-EOF
              #!/bin/bash
              # Update system
              apt-get update
              apt-get upgrade -y

              # Install prerequisites
              apt-get install -y \
                python3-pip \
                unzip \
                curl \
                pipx \
                git
              
              # Install awscli
              curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
              unzip awscliv2.zip
              ./aws/install

              # Install Wiz Sensor
              export WIZ_API_CLIENT_ID=$(aws ssm get-parameters --names ${var.wiz_api_client_id_ssm_parameter_name} --with-decryption --query "Parameters[].Value" --output text)
              export WIZ_API_CLIENT_SECRET=$(aws ssm get-parameters --names ${var.wiz_api_client_secret_ssm_parameter_name} --with-decryption --query "Parameters[].Value" --output text)
              sudo -E bash -c "$(curl -L https://downloads.wiz.io/sensor/sensor_install.sh)"

              # Install Stratus Red Team
              curl -sLo stratus.tar.gz https://github.com/DataDog/stratus-red-team/releases/latest/download/stratus-red-team_Linux_x86_64.tar.gz
              tar xzf stratus.tar.gz
              mv stratus /usr/local/bin/
              rm stratus.tar.gz

              # Install Pacu
              export PIPX_BIN_DIR="/usr/local/bin"
              export PIPX_HOME="/opt/pipx"
              pipx install pacu

              # Configure aws profile - Required for stratus
              mkdir -p /home/ubuntu/.aws
              cat <<EOT >> /home/ubuntu/.aws/config
              [default]
              role_arn = ${aws_iam_role.wiz_ec2_role.arn}
              credential_source = Ec2InstanceMetadata
              region = ${var.aws_region}
              EOT

              # 
              cat <<EOT >> /home/ubuntu/.bashrc
              export AWS_PAGER=""
              EOT
              cat <<EOT >> /etc/profile.d/custom-login-message.sh
              echo "Available tools:"
              echo " - AWS CLI: aws --version"
              echo " - Stratus Red Team: stratus version"
              echo " - Pacu: Use \"pacu\" command"
              echo ""
              EOT
              chmod +x /etc/profile.d/custom-login-message.sh
              EOF

  tags = {
    Name = "Instance-${random_string.role_suffix.result}"
  }
}