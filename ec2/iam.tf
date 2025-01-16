# Generate random string for IAM role name
resource "random_string" "role_suffix" {
  length  = 8
  special = false
  upper   = false
}

# Create IAM role
resource "aws_iam_role" "wiz_ec2_role" {
  name = "wiz-ec2-role-${random_string.role_suffix.result}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Attach administrator access policy to role
resource "aws_iam_role_policy_attachment" "admin_policy" {
  role       = aws_iam_role.wiz_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# Create instance profile
resource "aws_iam_instance_profile" "wiz_ec2_profile" {
  name = "wiz-ec2-profile-${random_string.role_suffix.result}"
  role = aws_iam_role.wiz_ec2_role.name
}