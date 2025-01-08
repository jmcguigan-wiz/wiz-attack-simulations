# Create ECS Cluster
resource "aws_ecs_cluster" "wiz_ecs_cluster" {
  name = var.ecs_cluster_name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name = var.ecs_cluster_name
  }
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "cwl_fargate_attack_scenario" {
  name              = "/ecs/wiz-fargate-attack-scenario"
  retention_in_days = 30
}
resource "aws_cloudwatch_log_group" "cwl_redteam_attack_scenario" {
  name              = "/ecs/wiz-aws-redteam-simulation"
  retention_in_days = 30
}

resource "aws_ecs_task_definition" "wiz_fargate_attack_scenario_task_def" {
  family                   = "wiz-fargate-attack-scenario"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "1024"
  memory                   = "3072"

  runtime_platform {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }

  execution_role_arn = aws_iam_role.wiz_task_execution_role.arn
  task_role_arn      = aws_iam_role.wiz_task_role.arn

  container_definitions = jsonencode([
    {
      name  = "wiz-fargate-attack-scenario"
      image = "wizio.azurecr.io/sensor-serverless-demo:v1"
      repositoryCredentials = {
        credentialsParameter = "${aws_secretsmanager_secret.wiz_registry_credentials.arn}"
      }
      cpu             = 0
      essential       = true
      entrypoint      = ["/opt/wiz/sensor/wiz-sensor", "daemon", "--"]
      command         = ["bash", "-c", "${var.wiz_fargate_attack_scenario_command}"]
      portmappings    = []
      mount_points    = []
      system_controls = []
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "${aws_cloudwatch_log_group.cwl_fargate_attack_scenario.name}"
          "awslogs-region"        = "${var.aws_region}"
          "awslogs-stream-prefix" = "ecs"
        }
      }
      environment = [
        {
          name  = "WIZ_AWAIT_ENGINE_READY"
          value = "true"
        }
      ]
      secrets = [
        {
          name      = "WIZ_API_CLIENT_ID"
          valueFrom = "${aws_secretsmanager_secret.wiz_sensor_service_account.arn}:WIZ_API_CLIENT_ID::"
        },
        {
          name      = "WIZ_API_CLIENT_SECRET"
          valueFrom = "${aws_secretsmanager_secret.wiz_sensor_service_account.arn}:WIZ_API_CLIENT_SECRET::"
        }
      ]
    }
  ])
}

resource "aws_ecs_task_definition" "wiz_aws_redteam_simulation" {
  family                   = "wiz-aws-redteam-simulation"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "1024"
  memory                   = "3072"
  task_role_arn            = aws_iam_role.wiz_task_role.arn
  execution_role_arn       = aws_iam_role.wiz_task_execution_role.arn

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  container_definitions = jsonencode([
    {
      name       = "wiz-aws-redteam-simulation"
      image      = "jamcg/wiz-aws-redteam-simulation:latest"
      cpu        = 0
      essential  = true
      entryPoint = ["/opt/wiz/sensor/wiz-sensor", "daemon", "--"]
      command    = ["sleep", "infinity"]

      environment = [
        {
          name  = "WIZ_BACKEND_ENV"
          value = "prod"
        }
      ]

      secrets = [
        {
          name      = "WIZ_API_CLIENT_ID"
          valueFrom = "${aws_secretsmanager_secret.wiz_sensor_service_account.arn}:WIZ_API_CLIENT_ID::"
        },
        {
          name      = "WIZ_API_CLIENT_SECRET"
          valueFrom = "${aws_secretsmanager_secret.wiz_sensor_service_account.arn}:WIZ_API_CLIENT_SECRET::"
        }
      ]

      volumesFrom = [
        {
          sourceContainer = "wiz-sensor"
        }
      ]

      linuxParameters = {
        capabilities = {
          add  = ["SYS_PTRACE"]
          drop = []
        }
      }

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "${aws_cloudwatch_log_group.cwl_redteam_attack_scenario.name}"
          "awslogs-region"        = "${var.aws_region}"
          "awslogs-stream-prefix" = "ecs"
        }
      }
    },
    {
      name      = "wiz-sensor"
      image     = "wizio.azurecr.io/sensor-serverless:v1"
      essential = false

      repositoryCredentials = {
        credentialsParameter = "${aws_secretsmanager_secret.wiz_registry_credentials.arn}"
      }
    }
  ])
}