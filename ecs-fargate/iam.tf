data "aws_iam_policy_document" "ecs_assume_role_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# task execution role
resource "aws_iam_role" "wiz_task_execution_role" {
  name               = "wiz-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "wiz_task_execution_role_policy_attachment" {
  role       = aws_iam_role.wiz_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy" "allow_reading_wiz_secrets" {
  name = "allow-reading-wiz-secrets"
  role = aws_iam_role.wiz_task_execution_role.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["secretsmanager:GetSecretValue"]
        Resource = [
          aws_secretsmanager_secret.wiz_registry_credentials.arn,
          aws_secretsmanager_secret.wiz_sensor_service_account.arn,
        ]
      },
    ]
  })
}

# Generate a random suffix for the ECS task role to create a unique role name on each creation
resource "random_string" "role_suffix" {
  length  = 4
  special = false
  upper   = false
}

# task role
resource "aws_iam_role" "wiz_task_role" {
  name               = "wiz-task-role-${random_string.role_suffix.result}"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role_policy.json
}

resource "aws_iam_policy" "wiz_task_role_policy" {
  name        = "wiz-task-role-policy"
  description = "Policy to allow ECS Exec to use SSM messages"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement : [
      {
        Effect = "Allow",
        Action = [
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "wiz_task_role_policy_attachment" {
  role       = aws_iam_role.wiz_task_role.name
  policy_arn = aws_iam_policy.wiz_task_role_policy.arn
}

resource "aws_iam_role_policy_attachment" "wiz_task_role_admin_policy_attachment" {
  role       = aws_iam_role.wiz_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}