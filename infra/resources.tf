resource "aws_cloudwatch_log_group" "query-log-group" {
  name_prefix       = "mod-${local.subdomain}-dns-queries-"
  retention_in_days = 3
  provider          = aws.us-east-1
}

resource "aws_cloudwatch_log_resource_policy" "query-log-resource-policy" {
  policy_document = data.aws_iam_policy_document.query-log-group-policy-document.json
  policy_name     = random_id.query-log-resource-policy-name.dec
  provider        = aws.us-east-1
}

resource "aws_cloudwatch_log_subscription_filter" "query-log-subscription-filter" {
  destination_arn = aws_lambda_function.autoscaler-lambda.arn
  filter_pattern  = local.subdomain
  log_group_name  = aws_cloudwatch_log_group.query-log-group.name
  name            = random_id.query-log-subscription-filter-name.dec
  provider        = aws.us-east-1
}

resource "aws_ecs_cluster" "cluster" {
  name = random_id.cluster-name.dec

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_cluster_capacity_providers" "cluster-capacity-provider" {
  capacity_providers = ["FARGATE"]
  cluster_name       = aws_ecs_cluster.cluster.name

  default_capacity_provider_strategy {
    base              = 1
    capacity_provider = "FARGATE"
    weight            = 100
  }
}

resource "aws_ecs_task_definition" "task-definition" {
  container_definitions = jsonencode([
    {
      essential        = false
      image            = local.minecraft_server_config["image"]
      logConfiguration = var.server_debug ? {
        logDriver = "awslogs"
        options   = {
          "awslogs-logRetentionDays" = 3
          "awslogs-stream-prefix"    = local.minecraft_server_container_name
        }
      } : null
      name         = local.minecraft_server_container_name
      portMappings = [
        {
          containerPort = local.minecraft_server_config["port"]
          hostPort      = local.minecraft_server_config["port"]
          protocol      = local.minecraft_server_config["protocol"]
        }
      ]
      mountPoints = [
        {
          containerPath = "/data"
          readOnly      = false
          sourceVolume  = local.ecs_volume_name,
        }
      ]
    }
  ])

  family        = random_id.task-definition-family.dec
  cpu           = var.server_cpu_units
  memory        = var.server_memory
  task_role_arn = aws_iam_role.task-definition-role.arn

  volume {
    name = local.ecs_volume_name

    efs_volume_configuration {
      file_system_id     = aws_efs_file_system.file-system.id
      transit_encryption = "ENABLED"

      authorization_config {
        access_point_id = aws_efs_access_point.file-system-access-point.id
        iam             = "ENABLED"
      }
    }
  }
}

resource "aws_efs_access_point" "file-system-access-point" {
  file_system_id = aws_efs_file_system.file-system.id

  posix_user {
    gid = local.efs_gid
    uid = local.efs_uid
  }

  root_directory {
    creation_info {
      owner_gid   = local.efs_gid
      owner_uid   = local.efs_uid
      permissions = "0755"
    }

    path = "/minecraft"
  }
}

resource "aws_efs_file_system" "file-system" {
  encrypted = true

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name = random_id.file-system-name.dec
  }
}

resource "aws_iam_policy" "file-system-policy" {
  name_prefix = "mod-file-system-policy-"
  policy      = data.aws_iam_policy_document.file-system-policy-document.json
}

resource "aws_iam_role" "autoscaler-lambda-role" {
  assume_role_policy = data.aws_iam_policy_document.autoscaler-lambda-policy-document.json
  name_prefix        = "mod-${local.subdomain}-"
  provider           = aws.us-east-1
}

resource "aws_iam_role" "task-definition-role" {
  assume_role_policy = data.aws_iam_policy_document.task-definition-assume-role-policy-document.json
}

resource "aws_iam_role_policy_attachment" "autoscaler-lambda-basic-execution-policy-attachment" {
  policy_arn = data.aws_iam_policy.autoscaler-lambda-basic-execution-policy.arn
  provider   = aws.us-east-1
  role       = aws_iam_role.autoscaler-lambda-role.name
}

resource "aws_iam_role_policy_attachment" "task-definition-role-file-system-policy-attachment" {
  policy_arn = aws_iam_policy.file-system-policy.arn
  role       = aws_iam_role.task-definition-role.name
}

resource "aws_lambda_function" "autoscaler-lambda" {
  filename         = data.archive_file.autoscaler-lambda.output_path
  function_name    = random_id.autoscaler-lambda-name.dec
  handler          = "autoscaler.handler"
  provider         = aws.us-east-1
  role             = aws_iam_role.autoscaler-lambda-role.arn
  runtime          = "python3.8"
  source_code_hash = data.archive_file.autoscaler-lambda.output_base64sha256

  // TODO add REGION: config.serverRegion, CLUSTER: constants.CLUSTER_NAME, SERVICE: constants.SERVICE_NAME
  environment {
    variables = {
    }
  }
}

resource "aws_lambda_permission" "query-log-lambda-permission" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.autoscaler-lambda.function_name
  principal     = "logs.amazonaws.com"
  source_arn    = "${aws_cloudwatch_log_group.query-log-group.arn}:*"
  provider      = aws.us-east-1
}

resource "aws_route53_query_log" "query-log" {
  cloudwatch_log_group_arn = aws_cloudwatch_log_group.query-log-group.arn
  provider                 = aws.us-east-1
  zone_id                  = aws_route53_zone.hosted-zone.zone_id
}

// dummy record, to be changed whenever the container launches
// which is why changes to the `records` property are ignored
resource "aws_route53_record" "hosted-zone-a-record" {
  name     = local.subdomain
  provider = aws.us-east-1
  records  = ["192.168.1.1"]
  ttl      = 30
  type     = "A"
  zone_id  = data.aws_route53_zone.root-hosted-zone.zone_id

  lifecycle {
    ignore_changes = [
      records
    ]
  }
}

resource "aws_route53_record" "root-hosted-zone-ns-record" {
  name     = local.subdomain
  provider = aws.us-east-1
  records  = aws_route53_zone.hosted-zone.name_servers
  ttl      = 172800
  type     = "NS"
  zone_id  = data.aws_route53_zone.root-hosted-zone.zone_id
}

resource "aws_route53_zone" "hosted-zone" {
  name     = local.subdomain
  provider = aws.us-east-1
}

resource "random_id" "autoscaler-lambda-name" {
  byte_length = 10
  prefix      = "mod-autoscaler-"
}

resource "random_id" "cluster-name" {
  byte_length = 10
  prefix      = "mod-cluster-"
}

resource "random_id" "file-system-name" {
  byte_length = 10
  prefix      = "mod-file-system-"
}

resource "random_id" "query-log-resource-policy-name" {
  byte_length = 10
  prefix      = "mod-${local.subdomain}-"
}

resource "random_id" "query-log-subscription-filter-name" {
  byte_length = 10
  prefix      = "mod-${local.subdomain}-"
}

resource "random_id" "task-definition-family" {
  byte_length = 10
  prefix      = "mod-task-definition-"
}
